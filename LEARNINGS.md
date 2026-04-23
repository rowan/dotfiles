# Learnings

Lessons captured from past work to inform future development. Updated when merging PRs.

---

## Dotfiles patterns

- **Prefer symlinks over copies**: Symlinked config files stay in sync with the repo automatically. Use `ln -s` instead of `cp` for anything that might change. This applies to skills directories, not just individual config files.

- **Updating a script doesn't apply the change**: If you modify an install script (e.g., changing `cp` to `ln -s`), the old state persists until you actually run the script. Don't assume the change is live just because you committed it.

- **Timestamp backup filenames beat numbered suffixes**: `file.bak.$(date +%Y%m%d-%H%M%S)` is self-documenting and can't clobber prior backups. Numbered suffixes (`.bak.1`, `.bak.2`) require exists-checking and can race.

- **`settings.json` is a bad symlink target when the app writes back**: Claude Code writes `feedbackSurveyState` to `~/.claude/settings.json` on its own. If symlinked into the dotfiles repo, every timestamp update creates git churn. Use `jq` to merge in place, preserving an explicit allowlist of transient keys.

## Claude Code config

- **Skill vs slash command vs sub-agent vs hook**: Skill = model-invoked ambient methodology (Claude picks when). Slash command = user-invoked discrete action (you type `/name`). Sub-agent = fresh-context specialist that returns findings (read-only, doesn't mutate state). Hook = harness-level automation on Claude Code events. Rule of thumb: if the trigger is fuzzy or the action costs external money/time, it's a slash command, not a skill.

- **Hooks fire on Claude Code events only, not external events**: `Stop`, `PreToolUse`, `SessionStart` etc. There is no "PR pushed" or "PR merged" hook. For external-event automation use GitHub Actions. Don't try to bolt it onto `PreToolUse` matchers against `gh pr merge` — brittle and misses the GitHub UI path.

- **AGENTS.md at repo root, minimal CLAUDE.md imports it**: Cross-tool convention (Cursor, Codex, Aider all read AGENTS.md). A `CLAUDE.md` containing just `@AGENTS.md` is the documented minimal form.

- **`.claude/settings.local.json` must be gitignored**: Claude Code writes per-project permission grants there. Sub-agents probing during review can accumulate dangerous entries like `Bash(rm -rf *)`. Never commit this file.

- **Claude Code auto-updates on launch**: No need for explicit `claude update` in install scripts unless `DISABLE_AUTOUPDATER` is set or auto-update is disabled in settings.

## Shell patterns

- **bash 3.2 (macOS default) needs `${arr[@]+"${arr[@]}"}` for empty arrays under `set -u`**: Plain `"${arr[@]}"` on an empty array throws "unbound variable". Matters especially in `trap` handlers that can fire before any appends happen.

- **`set -e` in a sourcing parent propagates to sourced children**: `scripts/update.zsh` uses `set -e` and sources `apps/*/install.zsh`. A `jq` call that errors on null input kills the whole `dot` run, not just the install step. Use defensive `// {}` guards and `|| { ... }` wrappers on risky operations.

- **jq's `*` merge is append-only**: Removing keys from the source file doesn't remove them from the target. For "repo is source of truth" semantics, use `$repo + (only-transient-keys-from-live)` with an explicit transient allowlist rather than `$repo * $live`.

- **Modern macOS (Sequoia 15+) ships `jq` at `/usr/bin/jq`**: Tests that try to force a grep fallback via `PATH=/usr/bin:/bin` silently hit the real jq and pass vacuously. Use an empty shim directory as PATH to genuinely remove jq from a test environment.

## GitHub CLI

- **Resolve PR comment threads via GraphQL**: Use `gh api graphql` with the `resolveReviewThread` mutation to programmatically mark review threads as resolved. Requires the thread's node ID from the `reviewThreads` query.

- **`gh api graphql -f key=value` defines GraphQL variables**: Any `-f` pair alongside `-f query=...` becomes a variable in the mutation. Useful for bodies containing quotes/colons that are awkward to inline: `gh api graphql -f threadId=PRRT_... -f body='...' -f query='mutation($threadId: ID!, $body: String!) { ... }'`.

## Code review

- **Verify Copilot PR review claims before applying**: In a sample of 3 comments on one PR, all 3 were confidently wrong: false claims about macOS `mktemp` semantics, and missing context about what's in the Brewfile. Always run the failing case yourself before changing code to match a review suggestion.
