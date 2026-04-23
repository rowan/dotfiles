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

run() {
  local label="$1"; shift
  local output rc cmd
  output=$("$@" 2>&1)
  rc=$?
  if (( rc != 0 )); then
    # printf '%q' shell-quotes each arg so space-containing args render
    # unambiguously in the error output.
    cmd=$(printf '%q ' "$@")
    errors+=("[$label] exit $rc: ${cmd% }"$'\n'"$output")
  fi
}

# Project-local verify wins
if [[ -x .claude/verify.sh ]]; then
  if ! output=$(.claude/verify.sh fast 2>&1); then
    errors+=("[project-verify-fast]"$'\n'"$output")
  fi
else
  # Auto-detect — FAST CHECKS ONLY
  if [[ -f Gemfile ]]; then
    [[ -f bin/rubocop ]] && run "rubocop" bin/rubocop --force-exclusion
  fi

  if [[ -f package.json ]]; then
    if command -v pnpm >/dev/null; then pm=pnpm
    elif command -v npm >/dev/null; then pm=npm
    else pm=""
    fi
    if [[ -n "$pm" ]]; then
      grep -q '"typecheck"' package.json && run "typecheck" $pm run typecheck
      grep -q '"lint"'      package.json && run "lint"      $pm run lint
    fi
  fi

  if compgen -G "*.xcodeproj" >/dev/null || compgen -G "*.xcworkspace" >/dev/null || [[ -f Package.swift ]]; then
    command -v swiftlint >/dev/null && run "swiftlint" swiftlint --quiet
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
