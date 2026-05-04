#!/usr/bin/env bash
# ~/.claude/hooks/verify.sh
# Stop hook — runs FAST checks only (target: under 60 seconds).
# Full build + slow tests belong in the verifier sub-agent or CI.
#
# Hooks receive JSON on stdin. We read stop_hook_active to avoid infinite loops:
# Claude Code sets it to true if this hook has already blocked once in this turn.

# Deliberately no `set -e`: the run() helper below accumulates failures
# from multiple checks into the errors array, and we want every check to
# run even if an earlier one fails.
set -uo pipefail

# Cap each individual check's stderr block before feeding it back to Claude.
# A repo-wide lint can spew thousands of lines and blow out the context
# window; 8K chars is enough to see the first dozen failures and bounded
# against worst-case. Note: bash's ${#s} and ${s:0:N} count characters in a
# UTF-8 locale, not bytes — fine for ~ASCII linter output, but the cap can
# be larger than this in actual bytes if the output contains multibyte chars.
MAX_OUTPUT_CHARS=8192

# Read stdin payload and check stop_hook_active
INPUT=$(cat 2>/dev/null || echo '{}')
if command -v jq >/dev/null 2>&1; then
  # Empty result on malformed JSON is fine: the [[ == "true" ]] check below
  # will treat it as not-active and proceed to run checks (fail-open).
  active=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
else
  # Fallback: matches the literal `true` value only; relies on Claude Code
  # emitting compact JSON.
  active=$(echo "$INPUT" | grep -o '"stop_hook_active"[[:space:]]*:[[:space:]]*true' >/dev/null 2>&1 && echo true || echo false)
fi
if [[ "$active" == "true" ]]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || {
  echo "verify.sh: could not cd to ${CLAUDE_PROJECT_DIR:-$PWD}; skipping" >&2
  exit 0
}
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Nothing changed, nothing to verify
if git diff --quiet && git diff --staged --quiet; then
  exit 0
fi

errors=()

# Truncate to MAX_OUTPUT_CHARS if longer; the suffix tells the agent the
# full length so it knows there's more behind the cap.
truncate_output() {
  local s="$1" len=${#1}
  if (( len > MAX_OUTPUT_CHARS )); then
    s="${s:0:$MAX_OUTPUT_CHARS}"
    s+=$'\n... (output truncated; full length: '"$len"' chars)'
  fi
  printf '%s' "$s"
}

run() {
  local label="$1"; shift
  local output rc cmd
  output=$("$@" 2>&1)
  rc=$?
  if (( rc != 0 )); then
    # printf '%q' shell-quotes each arg so space-containing args render
    # unambiguously in the error output.
    cmd=$(printf '%q ' "$@")
    output=$(truncate_output "$output")
    errors+=("[$label] exit $rc: ${cmd% }"$'\n'"$output")
  fi
}

# Print working-tree paths matching any of the given space-separated
# extensions, one per line. Scope is staged + unstaged + untracked, with
# deletions excluded. Working tree (not main..HEAD) keeps the list bounded
# regardless of branch age — long-lived branches were the original
# context-blowout source.
#
# In a brand-new repo with no HEAD yet, `git diff HEAD` errors. Fall back
# to "everything in the index plus untracked" so initial-commit work still
# gets linted.
changed_files() {
  local pattern="${1// /|}"
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    {
      git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null
    } | grep -E "\.($pattern)$" 2>/dev/null
  else
    {
      git ls-files --cached 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null
    } | grep -E "\.($pattern)$" 2>/dev/null
  fi
  return 0
}

# Project-local verify wins
if [[ -x .claude/verify.sh ]]; then
  if ! output=$(.claude/verify.sh fast 2>&1); then
    output=$(truncate_output "$output")
    errors+=("[project-verify-fast]"$'\n'"$output")
  fi
else
  # Auto-detect — FAST CHECKS ONLY, scoped to changed files where the linter
  # accepts file-list args. Projects whose linters don't fit this shape
  # (Biome, Oxlint, custom wrappers) should add a project-local
  # .claude/verify.sh fast.

  if [[ -f Gemfile && -f bin/rubocop ]]; then
    files=()
    while IFS= read -r f; do
      [[ -n "$f" ]] && files+=("$f")
    done < <(changed_files "rb")
    if (( ${#files[@]} > 0 )); then
      run "rubocop" bin/rubocop --force-exclusion "${files[@]}"
    fi
  fi

  if [[ -f package.json ]]; then
    if command -v pnpm >/dev/null; then pm=pnpm
    elif command -v npm >/dev/null; then pm=npm
    else pm=""
    fi
    if [[ -n "$pm" ]]; then
      grep -q '"typecheck"' package.json && run "typecheck" $pm run typecheck
    fi
    # Call the ESLint binary directly so we can pass file args. `pnpm run
    # lint` is unreliable here because lint scripts like `eslint .` ignore
    # extra arguments and lint the whole repo anyway.
    if [[ -x node_modules/.bin/eslint ]]; then
      files=()
      while IFS= read -r f; do
        [[ -n "$f" ]] && files+=("$f")
      done < <(changed_files "js jsx ts tsx mjs cjs")
      if (( ${#files[@]} > 0 )); then
        run "eslint" node_modules/.bin/eslint "${files[@]}"
      fi
    fi
  fi

  if compgen -G "*.xcodeproj" >/dev/null || compgen -G "*.xcworkspace" >/dev/null || [[ -f Package.swift ]]; then
    if command -v swiftlint >/dev/null; then
      files=()
      while IFS= read -r f; do
        [[ -n "$f" ]] && files+=("$f")
      done < <(changed_files "swift")
      if (( ${#files[@]} > 0 )); then
        run "swiftlint" swiftlint --quiet "${files[@]}"
      fi
    fi
  fi
fi

if (( ${#errors[@]} == 0 )); then
  exit 0
fi

# Exit code 2 blocks Claude from stopping; stderr is fed back to it.
{
  echo "Fast verification failed. Fix these before declaring the task complete:"
  echo
  for e in "${errors[@]}"; do
    echo "---"
    echo "$e"
    echo
  done
  echo "Full build + slow tests: run the 'verifier' sub-agent or wait for CI."
} >&2
exit 2
