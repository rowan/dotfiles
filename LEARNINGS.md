# Learnings

Lessons captured from past work to inform future development. Updated when merging PRs.

---

## Dotfiles patterns

- **Prefer symlinks over copies**: Symlinked config files stay in sync with the repo automatically. Use `ln -s` instead of `cp` for anything that might change. This applies to skills directories, not just individual config files.

- **Updating a script doesn't apply the change**: If you modify an install script (e.g., changing `cp` to `ln -s`), the old state persists until you actually run the script. Don't assume the change is live just because you committed it.

- **Timestamp backup filenames beat numbered suffixes**: `file.bak.$(date +%Y%m%d-%H%M%S)` is self-documenting and can't clobber prior backups. Numbered suffixes (`.bak.1`, `.bak.2`) require exists-checking and can race.

- **`settings.json` is a bad symlink target when the app writes back**: Claude Code writes `feedbackSurveyState` to `~/.claude/settings.json` on its own. If symlinked into the dotfiles repo, every timestamp update creates git churn. Use `jq` to merge in place, preserving an explicit allowlist of transient keys.

- **Verify a replaced tool's actual behaviour against live state, not its config**: When swapping `apply-user-defaults` (YAML) for plain `defaults write`, reading live `defaults read` values revealed the tool merged duplicate top-level YAML keys (a strict parser would have dropped one, silently losing a setting) and that a comment mislabelled `TrackpadThreeFingerTapGesture` as "Force Click" when it controls three-finger-tap look up. Config files carry latent inaccuracies; the running system is ground truth.

- **Safari defaults need Full Disk Access and exit codes aren't reliable**: `com.apple.Safari` prefs live in a TCC-protected container (`~/Library/Containers/com.apple.Safari/`), so Terminal needs Full Disk Access to write them. Worse, a write without FDA can still exit 0 by landing in a shadow plist, so an exit-code check can't fully confirm the setting reached Safari. Surface the raw stderr rather than asserting FDA as the only cause.

## Claude Code config

- **Skill vs slash command vs sub-agent vs hook**: Skill = model-invoked ambient methodology (Claude picks when). Slash command = user-invoked discrete action (you type `/name`). Sub-agent = fresh-context specialist that returns findings (read-only, doesn't mutate state). Hook = harness-level automation on Claude Code events. Rule of thumb: if the trigger is fuzzy or the action costs external money/time, it's a slash command, not a skill.

- **Hooks fire on Claude Code events only, not external events**: `Stop`, `PreToolUse`, `SessionStart` etc. There is no "PR pushed" or "PR merged" hook. For external-event automation use GitHub Actions. Don't try to bolt it onto `PreToolUse` matchers against `gh pr merge` — brittle and misses the GitHub UI path.

- **AGENTS.md at repo root, minimal CLAUDE.md imports it**: Cross-tool convention (Cursor, Codex, Aider all read AGENTS.md). A `CLAUDE.md` containing just `@AGENTS.md` is the documented minimal form.

- **`.claude/settings.local.json` must be gitignored**: Claude Code writes per-project permission grants there. Sub-agents probing during review can accumulate dangerous entries like `Bash(rm -rf *)`. Never commit this file.

- **Claude Code auto-updates on launch**: No need for explicit `claude update` in install scripts unless `DISABLE_AUTOUPDATER` is set or auto-update is disabled in settings.

## Shell patterns

- **bash 3.2 (macOS default) needs `${arr[@]+"${arr[@]}"}` for empty arrays under `set -u`**: Plain `"${arr[@]}"` on an empty array throws "unbound variable". Matters especially in `trap` handlers that can fire before any appends happen.

- **`set -e` in a sourcing parent propagates to sourced children**: `scripts/update.zsh` uses `set -e` and sources `apps/*/install.zsh`. A `jq` call that errors on null input kills the whole `dot` run, not just the install step. Use defensive `// {}` guards and `|| { ... }` wrappers on risky operations.

- **Locally disabling `set -e` in a sourced script must save and restore, not hardcode**: Because the script runs in the caller's shell, ending a best-effort block with a bare `set -e` would *enable* errexit in shells that never had it (e.g. an interactive `source scripts/defaults.zsh`). Capture the state first: `[[ -o errexit ]] && was=1 || was=; set +e; …; [[ -n $was ]] && set -e`. Complements the propagation note above.

- **Route repeated risky commands through a helper that records failures**: Instead of bare commands (abort the run under `set -e`) or `|| true` (swallow silently), a one-line `do_thing() { cmd "$@" || failed+=("$1"); }` wrapper plus an end-of-run summary keeps going *and* surfaces what broke. Used for the macOS `defaults write` block so one rejected key warns rather than aborting `dot`.

- **jq's `*` merge is append-only**: Removing keys from the source file doesn't remove them from the target. For "repo is source of truth" semantics, use `$repo + (only-transient-keys-from-live)` with an explicit transient allowlist rather than `$repo * $live`.

- **Modern macOS (Sequoia 15+) ships `jq` at `/usr/bin/jq`**: Tests that try to force a grep fallback via `PATH=/usr/bin:/bin` silently hit the real jq and pass vacuously. Use an empty shim directory as PATH to genuinely remove jq from a test environment.

- **bash `${#s}` and `${s:0:N}` count characters, not bytes, in UTF-8 locales**: macOS defaults to UTF-8. A 4-byte emoji is 1 character to bash. Fine for ASCII linter output, but a "max bytes" cap implemented this way is actually a max-chars cap. Name the constant accordingly (`MAX_OUTPUT_CHARS`, not `MAX_OUTPUT_BYTES`).

## Homebrew

- **Homebrew 6.0 added a tap-trust gate**: Third-party taps are skipped by `brew bundle` with "Skipping <tap> because it is not trusted" unless trusted via `brew trust --tap <tap>` (stored in `~/.homebrew/trust.json`, gated by `$HOMEBREW_REQUIRE_TAP_TRUST`). For reproducibility either trust the tap or drop the dependency. A stale, years-untouched third-party tap is exactly what the gate is meant to flag.

- **`brew bundle` is all-or-nothing on the lockfile**: A single transient cask download failure (e.g. a mirror connection reset) aborts the whole run and leaves `Brewfile.lock.json` unregenerated. Don't rely on it to clean stale lock entries; edit the lock directly or retry once the network settles.

- **`Brewfile.lock.json` is gitignored here** (`.gitignore:4`): It is not version-controlled, so `git diff main...HEAD` won't show edits to it and they won't appear in a PR. A successful `Edit` to a gitignored file produces no `git status` entry: don't mistake that for "no change", and don't claim the lock change in a PR description.

## Git

- **`git diff` and `git diff --staged` don't see untracked files**: A "is anything changed?" guard built from these two commands silently misses brand-new files. Use `git status --porcelain` (everything including untracked) or add `git ls-files --others --exclude-standard` to the check.

- **`git diff HEAD` errors on a brand-new repo**: No HEAD ref exists before the first commit. Scripts that target HEAD-relative diffs need to detect `git rev-parse --verify HEAD` failing and fall back to `git ls-files --cached` for the index contents.

- **`--diff-filter=ACMR` excludes deletions**: When piping changed files into a linter, you don't want deleted paths since they no longer exist on disk. ACMR keeps Added, Copied, Modified, Renamed.

## Hook design

- **Scope ambient hook checks to the working tree, not `main..HEAD`**: A long-lived branch produces an unbounded diff against main, which means unbounded lint output, which blows out the agent's context window. Working-tree scope (`git diff HEAD` ∪ untracked) is bounded by what's in front of you, not how old the branch is.

- **`pnpm run lint` doesn't reliably forward file args**: Many lint scripts hardcode the path, e.g. `"lint": "eslint ."`, so extra args after `--` get ignored or trip on the existing `.`. To lint a specific file list, invoke the binary directly (`node_modules/.bin/eslint <files>`). Same caveat for any wrapper script in package.json that puts a path in the script body.

- **Hard cap output before feeding it back to Claude**: A failing lint can emit thousands of lines that get piped into the agent's context as stderr. Truncate per-error block to a fixed cap, and *reserve space for the truncation suffix* before slicing so the cap stays hard rather than drifting by ~50 chars per block.

- **Match guard contracts to helper contracts**: If a new helper claims "staged + unstaged + untracked", any guard that short-circuits before calling it needs the same definition. Otherwise the guard's narrower view fires first and the helper never runs. Real case: a "nothing changed" early-exit using only `git diff` checks skipped untracked-only changes, even though the new scoping helper included them.

## GitHub CLI

- **Resolve PR comment threads via GraphQL**: Use `gh api graphql` with the `resolveReviewThread` mutation to programmatically mark review threads as resolved. Requires the thread's node ID from the `reviewThreads` query.

- **`gh api graphql -f key=value` defines GraphQL variables**: Any `-f` pair alongside `-f query=...` becomes a variable in the mutation. Useful for bodies containing quotes/colons that are awkward to inline: `gh api graphql -f threadId=PRRT_... -f body='...' -f query='mutation($threadId: ID!, $body: String!) { ... }'`.

## Code review

- **Verify Copilot PR review claims before applying**: Quality varies sharply between PRs. One early sample had 3/3 confidently wrong (false `mktemp` claims, missing Brewfile context); a later PR had 3/3 sound (caught a real char-vs-byte gotcha and a contract mismatch between an early-exit guard and a new scoping helper). Don't infer Copilot is reliably right or reliably wrong: read each suggestion in context, run the failing case yourself, and apply on merit.
