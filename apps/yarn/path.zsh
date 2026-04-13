# Only run yarn if we have a valid working directory
if [[ -d "$PWD" ]] && command -v yarn >/dev/null 2>&1; then
  YARN_GLOBAL_BIN="$(yarn global bin 2>/dev/null)"
  [[ -n "$YARN_GLOBAL_BIN" ]] && export PATH="$YARN_GLOBAL_BIN:$PATH"
fi