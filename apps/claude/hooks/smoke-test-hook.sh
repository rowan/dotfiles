#!/usr/bin/env bash
# smoke-test-hook.sh. Verify the Stop hook works correctly.
#
# Simulates what Claude Code does: pipes a JSON payload on stdin and checks
# the exit code + stderr output. Run manually after modifying verify.sh or
# to confirm the hook is wired up correctly.

# Deliberately no `set -e`: we collect failures and report at the end.
set -uo pipefail

HOOK="${HOOK:-$HOME/.claude/hooks/verify.sh}"

if [[ ! -x "$HOOK" ]]; then
  echo "error: hook not found or not executable at $HOOK" >&2
  echo "run 'dot' (or 'source scripts/install.zsh' from the dotfiles dir) first" >&2
  exit 1
fi

pass=0
fail=0

check() {
  local name="$1" expected_exit="$2" actual_exit="$3"
  if [[ "$actual_exit" == "$expected_exit" ]]; then
    echo "  ✓ $name (exit $actual_exit)"
    pass=$((pass+1))
  else
    echo "  ✗ $name (expected exit $expected_exit, got $actual_exit)"
    fail=$((fail+1))
  fi
}

# -F makes grep treat $needle as a fixed string, not a regex. Protects
# against future callers with `.`, `*`, `(`, etc. in the needle.
check_contains() {
  local name="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF -- "$needle"; then
    echo "  ✓ $name"
    pass=$((pass+1))
  else
    if [[ -z "$haystack" ]]; then
      echo "  ✗ $name (haystack was empty)"
    else
      echo "  ✗ $name (expected to find: $needle)"
      echo "     got: $haystack"
    fi
    fail=$((fail+1))
  fi
}

cleanup_dirs=()
# cd / avoids rm pulling the shell's cwd out from under us if a test was
# mid-pushd. The +"${...}" idiom is the bash 3.2-safe guard for an empty
# array under set -u.
trap 'cd /; for d in ${cleanup_dirs[@]+"${cleanup_dirs[@]}"}; do rm -rf "$d"; done' EXIT INT TERM

echo "Test 1: stop_hook_active=true short-circuits to exit 0"
exit_code=0
echo '{"stop_hook_active":true}' | "$HOOK" >/dev/null 2>&1 || exit_code=$?
check "loop guard" 0 "$exit_code"

echo
echo "Test 2: running outside a git repo exits 0"
# Unset CLAUDE_PROJECT_DIR so verify.sh's default of $PWD takes effect;
# otherwise the subshell still cd's into whatever Claude Code set for us.
exit_code=0
( unset CLAUDE_PROJECT_DIR; cd /tmp && echo '{"stop_hook_active":false}' | "$HOOK" >/dev/null 2>&1 ) || exit_code=$?
check "non-repo path" 0 "$exit_code"

echo
echo "Test 3: clean tree in a git repo exits 0"
cleandir=$(mktemp -d)
cleanup_dirs+=("$cleandir")
( cd "$cleandir" && git init -q && git config user.email "test@test" && git config user.name "test" && echo "ok" > file.txt && git add -A && git commit -q -m "init" )
exit_code=0
echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$cleandir" "$HOOK" >/dev/null 2>&1 || exit_code=$?
check "clean tree" 0 "$exit_code"

echo
echo "Test 4: dirty repo with failing project-local verify exits 2"
projectdir=$(mktemp -d)
cleanup_dirs+=("$projectdir")
if pushd "$projectdir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  echo "ok" > file.txt
  git add file.txt
  git commit -q -m "init"

  mkdir -p .claude
  cat > .claude/verify.sh <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "fast" ]]; then
  echo "synthetic fast-check failure" >&2
  exit 2
fi
exit 0
EOF
  chmod +x .claude/verify.sh

  echo "changed" >> file.txt

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$projectdir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "failing project-local fast check" 2 "$exit_code"
  check_contains "stderr contains project-verify output" "synthetic fast-check failure" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 4"
  fail=$((fail+1))
fi

echo
echo "Test 5: auto-detected Ruby project with failing rubocop exits 2"
rubydir=$(mktemp -d)
cleanup_dirs+=("$rubydir")
if pushd "$rubydir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  touch Gemfile
  mkdir -p bin
  cat > bin/rubocop <<'EOF'
#!/usr/bin/env bash
echo "synthetic rubocop failure" >&2
exit 1
EOF
  chmod +x bin/rubocop
  echo "ok" > file.txt
  git add -A
  git commit -q -m "init"
  echo "changed" >> file.txt

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$rubydir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "auto-detect rubocop failure" 2 "$exit_code"
  check_contains "stderr labelled [rubocop]" "[rubocop]" "$stderr_output"
  check_contains "stderr contains rubocop output" "synthetic rubocop failure" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 5"
  fail=$((fail+1))
fi

echo
echo "Test 6: staged-only changes still trigger verification"
stageddir=$(mktemp -d)
cleanup_dirs+=("$stageddir")
if pushd "$stageddir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  echo "ok" > file.txt
  git add file.txt
  git commit -q -m "init"

  mkdir -p .claude
  cat > .claude/verify.sh <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "fast" ]]; then
  echo "triggered on staged-only change" >&2
  exit 2
fi
exit 0
EOF
  chmod +x .claude/verify.sh

  echo "new line" >> file.txt
  git add file.txt

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$stageddir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "staged-only change triggers verify" 2 "$exit_code"
  check_contains "stderr includes the staged-change output" "triggered on staged-only change" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 6"
  fail=$((fail+1))
fi

echo
echo "Test 7: loop guard works without jq on PATH"
# Genuinely strip jq by running with a PATH that contains ONLY /bin plus an
# empty shim dir. Modern macOS ships jq at /usr/bin/jq, so omitting /usr/bin
# is the reliable way to force verify.sh into the grep fallback branch.
shim_dir=$(mktemp -d)
cleanup_dirs+=("$shim_dir")
# /bin has grep and cat but no jq. Add shim_dir first so `command -v jq`
# checks there first (empty dir = not found).
exit_code=0
echo '{"stop_hook_active":true}' | PATH="$shim_dir:/bin" "$HOOK" >/dev/null 2>&1 || exit_code=$?
check "loop guard via grep fallback" 0 "$exit_code"

echo
echo "Test 8: Node project with failing typecheck AND lint accumulates both errors"
nodedir=$(mktemp -d)
cleanup_dirs+=("$nodedir")
npm_shim_dir=$(mktemp -d)
cleanup_dirs+=("$npm_shim_dir")
cat > "$npm_shim_dir/npm" <<'EOF'
#!/usr/bin/env bash
echo "stub npm: $*" >&2
exit 1
EOF
chmod +x "$npm_shim_dir/npm"
if pushd "$nodedir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  cat > package.json <<'EOF'
{ "scripts": { "typecheck": "echo ts", "lint": "echo lint" } }
EOF
  echo "ok" > file.txt
  git add -A
  git commit -q -m "init"
  echo "changed" >> file.txt

  # PATH scoped to our shim dir + system basics (for git/cat/grep etc). Omits
  # /usr/local/bin etc. so any real pnpm/npm on the host doesn't leak in.
  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | PATH="$npm_shim_dir:/usr/bin:/bin" CLAUDE_PROJECT_DIR="$nodedir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "both npm checks trigger and fail" 2 "$exit_code"
  check_contains "stderr labelled [typecheck]" "[typecheck]" "$stderr_output"
  check_contains "stderr labelled [lint]" "[lint]" "$stderr_output"
  check_contains "stderr has --- separator (two entries)" "---" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 8"
  fail=$((fail+1))
fi

echo
echo "Result: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
