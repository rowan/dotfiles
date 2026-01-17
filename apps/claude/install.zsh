# Create symlink in the correct location for Claude Code
# Claude Code expects user-level config at ~/.claude/CLAUDE.md

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SOURCE="$DOTFILES/apps/claude/CLAUDE.md"

# Ensure ~/.claude directory exists
mkdir -p "$CLAUDE_DIR"

# Remove existing file/symlink if present
rm -f "$CLAUDE_MD"

# Create symlink
if ln -s "$SOURCE" "$CLAUDE_MD"; then
    echo "Linked \033[00;34m$SOURCE\033[0m to \033[00;34m$CLAUDE_MD\033[0m"
else
    echo "\033[00;31mFailed to create symlink: $CLAUDE_MD\033[0m"
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

# Install custom skills (symlink to keep in sync with dotfiles)
SKILLS_DIR="$HOME/.claude/skills"
SOURCE_SKILLS_DIR="$DOTFILES/apps/claude/skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
    echo "\033[00;33mWarning: Source skills directory not found: $SOURCE_SKILLS_DIR\033[0m"
else
    rm -rf "$SKILLS_DIR"
    if ln -s "$SOURCE_SKILLS_DIR" "$SKILLS_DIR"; then
        echo "Linked \033[00;34m$SOURCE_SKILLS_DIR\033[0m to \033[00;34m$SKILLS_DIR\033[0m"
    else
        echo "\033[00;31mFailed to create symlink: $SKILLS_DIR\033[0m"
    fi
fi
