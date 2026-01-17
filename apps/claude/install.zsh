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
ln -s "$SOURCE" "$CLAUDE_MD"

echo "Linked \033[00;34m$SOURCE\033[0m to \033[00;34m$CLAUDE_MD\033[0m"

# Install Claude Code plugins
claude plugin install frontend-design@claude-plugins-official
claude plugin install pr-review-toolkit@claude-plugins-official
