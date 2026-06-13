command -v tmux &>/dev/null || return 0

# Ensure tmux config symlink exists

TMUX_CONF="$HOME/.tmux.conf"
TMUX_SOURCE="$DOTFILES/apps/tmux/tmux.conf.symlink"

if [[ -L "$TMUX_CONF" ]]; then
    # Already a symlink - check it points to the right place
    if [[ "$(readlink "$TMUX_CONF")" != "$TMUX_SOURCE" ]]; then
        rm -f "$TMUX_CONF"
        ln -s "$TMUX_SOURCE" "$TMUX_CONF"
        echo "Updated tmux config symlink"
    fi
elif [[ -e "$TMUX_CONF" ]]; then
    # Exists but not a symlink - back it up
    mv "$TMUX_CONF" "$TMUX_CONF.backup"
    ln -s "$TMUX_SOURCE" "$TMUX_CONF"
    echo "Backed up existing ~/.tmux.conf and created symlink"
else
    # Doesn't exist - create it
    ln -s "$TMUX_SOURCE" "$TMUX_CONF"
    echo "Created tmux config symlink"
fi

# Projects config setup
CONFIG_DIR="$HOME/.config/tmux"
CONFIG_FILE="$CONFIG_DIR/projects"
DEFAULT_FILE="$DOTFILES/apps/tmux/default-projects"
OLD_CONFIG="$HOME/Documents/Code/.tmux-projects"

mkdir -p "$CONFIG_DIR"

if [[ -f "$OLD_CONFIG" ]] && [[ ! -f "$CONFIG_FILE" ]]; then
    # Migrate old config (note: old format was just project names, not full paths)
    migrated=0
    echo "# Migrated from old config - update to full paths" > "$CONFIG_FILE"
    while IFS= read -r project || [[ -n "$project" ]]; do
        [[ -z "$project" || "$project" =~ ^# ]] && continue
        echo "~/Documents/Code/$project" >> "$CONFIG_FILE"
        migrated=1
    done < "$OLD_CONFIG"
    if [[ "$migrated" -eq 1 ]]; then
        rm "$OLD_CONFIG"
        echo "Migrated tmux projects config to $CONFIG_FILE"
    else
        echo "Warning: Migration may have failed - keeping old config at $OLD_CONFIG"
    fi
elif [[ ! -f "$CONFIG_FILE" ]]; then
    # Copy default from repo
    cp "$DEFAULT_FILE" "$CONFIG_FILE"
    echo ""
    echo "⚠️  Created tmux projects config at $CONFIG_FILE"
    echo "   Edit this file to add your project paths for this machine."
    echo ""
fi

# Additive merge: keep the repo baseline in sync on existing machines.
# Appends any project path from default-projects that the live config is
# missing. Preserves machine-local entries and ordering; never removes.
if [[ -f "$CONFIG_FILE" ]] && [[ -f "$DEFAULT_FILE" ]]; then
    added=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        # Trim leading and trailing whitespace
        entry="${line#"${line%%[![:space:]]*}"}"
        entry="${entry%"${entry##*[![:space:]]}"}"
        [[ -z "$entry" ]] && continue
        # Append only if not already present as an exact line
        if ! grep -qxF "$entry" "$CONFIG_FILE"; then
            echo "$entry" >> "$CONFIG_FILE"
            echo "Added $entry to $CONFIG_FILE"
            added=1
        fi
    done < "$DEFAULT_FILE"
    if [[ "$added" -eq 1 ]]; then
        echo "Merged new baseline projects into $CONFIG_FILE"
    fi
fi
