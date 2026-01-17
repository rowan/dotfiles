# Learnings

Lessons captured from past work to inform future development. Updated when merging PRs.

---

## Dotfiles patterns

- **Prefer symlinks over copies**: Symlinked config files stay in sync with the repo automatically. Use `ln -s` instead of `cp` for anything that might change. This applies to skills directories, not just individual config files.

- **Updating a script doesn't apply the change**: If you modify an install script (e.g., changing `cp` to `ln -s`), the old state persists until you actually run the script. Don't assume the change is live just because you committed it.

## GitHub CLI

- **Resolve PR comment threads via GraphQL**: Use `gh api graphql` with the `resolveReviewThread` mutation to programmatically mark review threads as resolved. Requires the thread's node ID from the `reviewThreads` query.
