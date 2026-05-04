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
  echo "# ok" > foo.rb
  git add -A
  git commit -q -m "init"
  echo "# changed" >> foo.rb

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
echo "Test 8: Node project with failing typecheck AND eslint accumulates both errors"
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
  # ESLint is detected via the binary path, not the npm script — the hook
  # calls it directly so it can pass changed-file args.
  mkdir -p node_modules/.bin
  cat > node_modules/.bin/eslint <<'EOF'
#!/usr/bin/env bash
echo "synthetic eslint failure" >&2
exit 1
EOF
  chmod +x node_modules/.bin/eslint
  echo "let x = 1" > file.ts
  git add -A
  git commit -q -m "init"
  echo "let y = 2" >> file.ts

  # PATH scoped to our shim dir + system basics (for git/cat/grep etc). Omits
  # /usr/local/bin etc. so any real pnpm/npm on the host doesn't leak in.
  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | PATH="$npm_shim_dir:/usr/bin:/bin" CLAUDE_PROJECT_DIR="$nodedir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "both npm checks trigger and fail" 2 "$exit_code"
  check_contains "stderr labelled [typecheck]" "[typecheck]" "$stderr_output"
  check_contains "stderr labelled [eslint]" "[eslint]" "$stderr_output"
  check_contains "stderr has --- separator (two entries)" "---" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 8"
  fail=$((fail+1))
fi

echo
echo "Test 9: Ruby project with non-Ruby change skips rubocop entirely"
rubyskipdir=$(mktemp -d)
cleanup_dirs+=("$rubyskipdir")
if pushd "$rubyskipdir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  touch Gemfile
  mkdir -p bin
  # Fail loudly if invoked — the test asserts rubocop is NOT called when no
  # .rb files are in the working tree change set.
  cat > bin/rubocop <<'EOF'
#!/usr/bin/env bash
echo "rubocop should NOT have run" >&2
exit 1
EOF
  chmod +x bin/rubocop
  echo "ok" > README.md
  git add -A
  git commit -q -m "init"
  echo "changed" >> README.md

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$rubyskipdir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "non-Ruby change skips rubocop (exit 0)" 0 "$exit_code"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 9"
  fail=$((fail+1))
fi

echo
echo "Test 10: oversize check output is truncated, not dumped whole"
truncdir=$(mktemp -d)
cleanup_dirs+=("$truncdir")
if pushd "$truncdir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  echo "ok" > file.txt
  git add file.txt
  git commit -q -m "init"

  mkdir -p .claude
  # Emit ~50 KiB of output — well over the 8K-char MAX_OUTPUT_CHARS cap.
  cat > .claude/verify.sh <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "fast" ]]; then
  for i in $(seq 1 1000); do
    echo "synthetic line $i: padding bytes to push past the truncation cap" >&2
  done
  exit 2
fi
exit 0
EOF
  chmod +x .claude/verify.sh

  echo "changed" >> file.txt

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$truncdir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "oversize output still exits 2" 2 "$exit_code"
  check_contains "stderr contains truncation marker" "output truncated" "$stderr_output"
  # Cap is 8192 chars per error block; the wrapper text ("Fast verification
  # failed...", "---", footer) adds a few hundred more. 12288 (1.5x) is
  # enough slack for the wrapper without letting a doubling regression slip.
  size=${#stderr_output}
  if (( size < 12288 )); then
    echo "  ✓ stderr bounded (${size} chars < 12288)"
    pass=$((pass+1))
  else
    echo "  ✗ stderr too large (${size} chars, expected under 12288)"
    fail=$((fail+1))
  fi
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 10"
  fail=$((fail+1))
fi

echo
echo "Test 11: mixed-extension change set lints only the matching files"
mixeddir=$(mktemp -d)
cleanup_dirs+=("$mixeddir")
if pushd "$mixeddir" >/dev/null; then
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  touch Gemfile
  mkdir -p bin
  # Shim records its argv to a file we can inspect after the run.
  cat > bin/rubocop <<EOF
#!/usr/bin/env bash
echo "\$@" > "$mixeddir/rubocop_args"
echo "synthetic rubocop failure" >&2
exit 1
EOF
  chmod +x bin/rubocop
  echo "# ok" > foo.rb
  echo "ok" > README.md
  git add -A
  git commit -q -m "init"
  echo "# changed" >> foo.rb
  echo "changed" >> README.md

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$mixeddir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "rubocop runs (exit 2)" 2 "$exit_code"
  if [[ -f rubocop_args ]]; then
    args=$(cat rubocop_args)
    check_contains "rubocop received foo.rb" "foo.rb" "$args"
    if echo "$args" | grep -qF "README.md"; then
      echo "  ✗ rubocop received README.md (should not have): $args"
      fail=$((fail+1))
    else
      echo "  ✓ rubocop did not receive README.md"
      pass=$((pass+1))
    fi
  else
    echo "  ✗ rubocop_args file missing — shim not invoked"
    fail=$((fail+1))
  fi
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 11"
  fail=$((fail+1))
fi

echo
echo "Test 12: initial-commit (no HEAD) repo still lints staged Ruby files"
initdir=$(mktemp -d)
cleanup_dirs+=("$initdir")
if pushd "$initdir" >/dev/null; then
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
  echo "# ok" > foo.rb
  # Stage but do NOT commit — there's no HEAD at this point.
  git add -A

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$initdir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "no-HEAD repo with staged .rb still triggers rubocop" 2 "$exit_code"
  check_contains "stderr labelled [rubocop]" "[rubocop]" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 12"
  fail=$((fail+1))
fi

echo
echo "Test 13: untracked-only changes still trigger the hook"
untrackeddir=$(mktemp -d)
cleanup_dirs+=("$untrackeddir")
if pushd "$untrackeddir" >/dev/null; then
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
  echo "ok" > existing.txt
  git add -A
  git commit -q -m "init"
  # New, untracked .rb file. Nothing modified, nothing staged.
  echo "# new" > new.rb

  exit_code=0
  stderr_output=$(echo '{"stop_hook_active":false}' | CLAUDE_PROJECT_DIR="$untrackeddir" "$HOOK" 2>&1 >/dev/null) || exit_code=$?
  check "untracked-only .rb still triggers rubocop" 2 "$exit_code"
  check_contains "stderr labelled [rubocop]" "[rubocop]" "$stderr_output"
  popd >/dev/null
else
  echo "  ✗ pushd failed for test 13"
  fail=$((fail+1))
fi

echo
echo "Result: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
