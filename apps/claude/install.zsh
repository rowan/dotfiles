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

# Install Claude Code plugins (official)
claude plugin install frontend-design@claude-plugins-official
claude plugin install pr-review-toolkit@claude-plugins-official

# Install custom skills (symlink to keep in sync with dotfiles)
SKILLS_DIR="$HOME/.claude/skills"
SOURCE_SKILLS_DIR="$DOTFILES/apps/claude/skills"
rm -rf "$SKILLS_DIR"
ln -s "$SOURCE_SKILLS_DIR" "$SKILLS_DIR"
echo "Linked \033[00;34m$SOURCE_SKILLS_DIR\033[0m to \033[00;34m$SKILLS_DIR\033[0m"
