# Set up Claude Code user config at ~/.claude/
# Directory-level symlinks so edits in the repo flow through immediately.
# settings.json is merged (not symlinked) to preserve transient keys that
# Claude Code writes back to the file (e.g. feedbackSurveyState).

CLAUDE_DIR="$HOME/.claude"
SOURCE_DIR="$DOTFILES/apps/claude"

mkdir -p "$CLAUDE_DIR"

# link_path SRC TARGET
# - If TARGET is already a symlink to SRC, no-op.
# - If TARGET is a symlink pointing elsewhere, remove and re-link (no backup;
#   the old link target is left untouched).
# - If TARGET is a regular file byte-identical to SRC, replace with symlink
#   (no backup needed).
# - If TARGET is any other regular file, or a directory, back it up to
#   TARGET.bak.YYYYMMDD-HHMMSS before symlinking. Timestamp suffix keeps
#   repeat runs from clobbering an earlier backup.
link_path() {
    local src="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        if [[ "$(readlink "$target")" == "$src" ]]; then
            return 0
        fi
        rm "$target" || { echo "  error: failed to remove stale symlink $target" >&2; return 1; }
    elif [[ -e "$target" ]]; then
        if [[ -f "$src" && -f "$target" ]] && cmp -s "$src" "$target"; then
            rm "$target" || { echo "  error: failed to remove identical $target" >&2; return 1; }
        else
            local bak="$target.bak.$(date +%Y%m%d-%H%M%S)"
            mv "$target" "$bak" || { echo "  error: failed to back up $target -> $bak" >&2; return 1; }
            echo "  Backed up $target -> $bak"
        fi
    fi

    ln -s "$src" "$target" || { echo "  error: failed to symlink $src -> $target" >&2; return 1; }
    echo "  Linked $target -> $src"
}

echo "▶️  Symlink Claude Code config"
link_path "$SOURCE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link_path "$SOURCE_DIR/skills"    "$CLAUDE_DIR/skills"
link_path "$SOURCE_DIR/commands"  "$CLAUDE_DIR/commands"
link_path "$SOURCE_DIR/agents"    "$CLAUDE_DIR/agents"
link_path "$SOURCE_DIR/hooks"     "$CLAUDE_DIR/hooks"

# Merge repo settings into live settings.json.
# Repo is source of truth for every key it defines; transient keys that
# Claude Code writes back to the file are preserved from live.
# Arrays (e.g. .hooks.Stop) are replaced wholesale by the repo version,
# not merged — any local Stop-hook entries would be overwritten.
echo "▶️  Merge settings.json"
LIVE="$CLAUDE_DIR/settings.json"
SRC="$SOURCE_DIR/settings.json"
TRANSIENT_KEYS='["feedbackSurveyState"]'

if ! command -v jq &> /dev/null; then
    echo "\033[00;33m  Warning: jq not found, skipping settings merge\033[0m"
elif [[ -f "$LIVE" ]]; then
    tmp=$(mktemp)
    if err=$(jq --argjson transient "$TRANSIENT_KEYS" -s '
        .[1] as $repo | .[0] as $live |
        $repo + (
            $transient
            | map({(.): $live[.]})
            | add // {}
            | with_entries(select(.value != null))
        )
    ' "$LIVE" "$SRC" 2>&1 > "$tmp"); then
        mv "$tmp" "$LIVE"
        echo "  Merged repo settings into $LIVE"
    else
        rm -f "$tmp"
        echo "\033[00;33m  Warning: jq merge failed for $LIVE: $err\033[0m"
        echo "\033[00;33m  Inspect the file manually or delete it to regenerate from repo default\033[0m"
    fi
elif cp "$SRC" "$LIVE"; then
    echo "  Created $LIVE from repo default"
else
    echo "\033[00;33m  Warning: failed to create $LIVE from $SRC\033[0m"
fi

# Install Claude Code plugins listed in settings.enabledPlugins.
# (The CLI itself auto-updates on launch, so we don't call `claude update` here.)
# We install every listed plugin; the true/false value is used by Claude
# Code at runtime, not here.
echo "▶️  Install Claude Code plugins"
if ! command -v claude &> /dev/null; then
    echo "\033[00;33m  Warning: claude CLI not found, skipping plugin installation\033[0m"
elif ! command -v jq &> /dev/null; then
    echo "\033[00;33m  Warning: jq not found, skipping plugin installation\033[0m"
else
    jq -r '.enabledPlugins // {} | keys[]' "$SRC" | while IFS= read -r plugin; do
        if output=$(claude plugin install "$plugin" 2>&1); then
            echo "  Installed: $plugin"
        else
            echo "\033[00;33m  Warning: failed to install $plugin:\033[0m"
            echo "$output" | sed 's/^/    /'
        fi
    done
fi
