# AGENTS.md

Project context for AI coding agents (Claude Code, Codex, Cursor, Aider, and other tools that read `AGENTS.md`). The repo-root `CLAUDE.md` imports this file.

## Repository Overview

This is a dotfiles repository for managing macOS development environment configuration. Configurations are organised by application in the `apps/` directory.

## Key Commands

### Initial Setup (new environment)
```bash
# Run from ~/.dotfiles directory
source scripts/install.zsh
```

### Update Environment
```bash
# Primary update command - runs all update scripts
dot

# Update dotfiles AND upgrade all Homebrew packages
dot --upgrade

# Edit dotfiles
dot --edit

# Manually update all Homebrew packages
brew upgrade

# List outdated packages
brew outdated
```

### Manual Script Execution
```bash
# Update homebrew packages
source scripts/homebrew.zsh

# Apply macOS defaults
source scripts/defaults.zsh

# Run app install scripts
source scripts/apps.zsh

# Setup terminal configuration
source scripts/terminal.zsh

# One-time cleanup for known issues (run as needed)
source scripts/cleanup.zsh
```

### Validating Claude Code hooks
```bash
# Run the smoke test after modifying apps/claude/hooks/verify.sh
~/.claude/hooks/smoke-test-hook.sh
```

## Architecture

### Directory Structure
- `apps/` - Application-specific configurations organised by tool
  - Each app directory can contain:
    - `*.symlink` - Files symlinked to `$HOME` during setup
    - `path.zsh` - PATH configuration (loaded first)
    - `*.zsh` - Configuration scripts (loaded second)
    - `completion.zsh` - Autocomplete setup (loaded last)
    - `install.zsh` - App-specific installation/update script

- `scripts/` - Core setup and update scripts
  - `install.zsh` - Initial environment setup
  - `update.zsh` - Environment update (called by `dot` command)
  - `terminal.zsh` - Terminal configuration and `.symlink` file creation
  - `homebrew.zsh` - Homebrew installation and package management
  - `defaults.zsh` - macOS system preferences
  - `apps.zsh` - Runs all `apps/*/install.zsh` scripts

- `bin/` - Custom commands added to PATH
  - `dot` - Primary dotfiles management command

- `functions/` - Shell functions available in terminal

### Claude Code Configuration (`apps/claude/`)

This app has a richer structure than the generic app pattern. `install.zsh` creates directory-level symlinks into `~/.claude/` so edits in the repo flow through immediately.

- `CLAUDE.md` - Global Claude Code instructions (symlinked to `~/.claude/CLAUDE.md`)
- `skills/` - Model-invoked skills (symlinked to `~/.claude/skills/`)
- `commands/` - User-invoked slash commands (symlinked to `~/.claude/commands/`)
- `agents/` - Claude Code sub-agents (symlinked to `~/.claude/agents/`)
- `hooks/` - Claude Code hook scripts, including the Stop hook `verify.sh` and its smoke test (symlinked to `~/.claude/hooks/`)
- `settings.json` - Claude Code settings; merged (not symlinked) into `~/.claude/settings.json` via `jq` so transient keys Claude Code writes back (e.g. `feedbackSurveyState`) are preserved. The repo is source of truth for every other key, including `enabledPlugins`
- `install.zsh` - Sets up the symlinks and runs the merge

### Loading Order

When terminal starts (via `~/.zshrc`):
1. Sets `$DOTFILES` environment variable
2. Sources all `path.zsh` files to configure PATH
3. Sources all other `*.zsh` files (except `install.zsh` and `completion.zsh`)
4. Initialises autocomplete
5. Sources all `completion.zsh` files

### Key Configuration Files

- **Homebrew**: `apps/homebrew/Brewfile` - Defines all brew packages, casks, and Mac App Store apps
- **Git**: `apps/git/gitconfig.symlink` - Global git configuration
- **Terminal**: `apps/terminal/zshrc.symlink` - Main zsh configuration
- **Ruby**: `apps/ruby/` - rbenv and Ruby configuration
- **Claude Code**: `apps/claude/` - See the Claude Code Configuration section above

### Environment Variables

- `$DOTFILES` - Set to `~/.dotfiles`
- `$PROJECTS` - Set to `~/Documents/Code` (project directory)

## Development Notes

- Symlinks for `*.symlink` files are created by `scripts/terminal.zsh`. Claude Code config symlinks are created by `apps/claude/install.zsh`, which also jq-merges `apps/claude/settings.json` into `~/.claude/settings.json` (repo wins for every key except transient ones like `feedbackSurveyState`)
- The `dot` command should be run periodically to keep everything updated
- App-specific install scripts in `apps/*/install.zsh` are run during updates
- The repository uses zsh as the default shell
- After modifying `apps/claude/hooks/verify.sh`, run `~/.claude/hooks/smoke-test-hook.sh` to validate the hook contract (exit codes, stderr forwarding to Claude Code, auto-detect branches)
