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
    echo "# Migrated from old config - update to full paths" > "$CONFIG_FILE"
    while IFS= read -r project || [[ -n "$project" ]]; do
        [[ -z "$project" || "$project" =~ ^# ]] && continue
        echo "~/Documents/Code/$project" >> "$CONFIG_FILE"
    done < "$OLD_CONFIG"
    rm "$OLD_CONFIG"
    echo "Migrated tmux projects config to $CONFIG_FILE"
elif [[ ! -f "$CONFIG_FILE" ]]; then
    # Copy default from repo
    cp "$DEFAULT_FILE" "$CONFIG_FILE"
    echo ""
    echo "⚠️  Created tmux projects config at $CONFIG_FILE"
    echo "   Edit this file to add your project paths for this machine."
    echo ""
fi
