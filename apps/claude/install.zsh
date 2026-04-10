# Set up Claude Code user config at ~/.claude/CLAUDE.md
# This file is personal to each user - we copy a default on first setup
# but never overwrite an existing config. Old symlinks from a previous
# install are migrated to local copies.

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SOURCE="$DOTFILES/apps/claude/CLAUDE.md"

mkdir -p "$CLAUDE_DIR"

if [[ -L "$CLAUDE_MD" ]]; then
    # Migrate from old symlink approach: replace with a real copy
    SOURCE_TARGET="$(readlink "$CLAUDE_MD")"
    if [[ -f "$SOURCE_TARGET" ]]; then
        rm "$CLAUDE_MD"
        cp "$SOURCE_TARGET" "$CLAUDE_MD"
    else
        # Broken symlink - fall back to repo default
        rm "$CLAUDE_MD"
        cp "$SOURCE" "$CLAUDE_MD"
    fi
    echo "Migrated $CLAUDE_MD from symlink to local copy"
    echo "  You can personalise this file with your own preferences."
elif [[ -e "$CLAUDE_MD" ]]; then
    # Real file already exists - don't touch it
    :
else
    # First-time setup: copy the default
    cp "$SOURCE" "$CLAUDE_MD"
    echo "Created $CLAUDE_MD with default config"
    echo "  Personalise this file with your name and preferences."
fi

# Install Claude Code plugins (official)
if command -v claude &> /dev/null; then
    for plugin in "frontend-design@claude-plugins-official" "pr-review-toolkit@claude-plugins-official"; do
        if claude plugin install "$plugin" 2>&1; then
            echo "Installed plugin: $plugin"
        else
            echo "\033[00;33mWarning: Failed to install plugin: $plugin\033[0m"
        fi
    done
else
    echo "\033[00;33mWarning: claude CLI not found, skipping plugin installation\033[0m"
fi

# Install default skills on first setup (users can add/modify their own)
SKILLS_DIR="$HOME/.claude/skills"
SOURCE_SKILLS_DIR="$DOTFILES/apps/claude/skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
    echo "\033[00;33mWarning: Source skills directory not found: $SOURCE_SKILLS_DIR\033[0m"
elif [[ -L "$SKILLS_DIR" ]]; then
    # Migrate from old symlink approach: replace with a real copy
    rm "$SKILLS_DIR"
    cp -R "$SOURCE_SKILLS_DIR" "$SKILLS_DIR"
    echo "Migrated $SKILLS_DIR from symlink to local copy"
elif [[ -d "$SKILLS_DIR" ]]; then
    # Skills directory already exists - don't touch it
    :
else
    # First-time setup: copy the defaults
    cp -R "$SOURCE_SKILLS_DIR" "$SKILLS_DIR"
    echo "Created default skills at $SKILLS_DIR"
fi
