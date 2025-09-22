# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for managing macOS development environment configuration. The repository uses a modular approach where configurations are organized by application in the `apps/` directory.

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

## Architecture

### Directory Structure
- `apps/` - Application-specific configurations organized by tool
  - Each app directory can contain:
    - `*.symlink` - Files symlinked to `$HOME` during setup
    - `path.zsh` - PATH configuration (loaded first)
    - `*.zsh` - Configuration scripts (loaded second)
    - `completion.zsh` - Autocomplete setup (loaded last)
    - `install.zsh` - App-specific installation scripts

- `scripts/` - Core setup and update scripts
  - `install.zsh` - Initial environment setup
  - `update.zsh` - Environment update (called by `dot` command)
  - `terminal.zsh` - Terminal configuration and symlink creation
  - `homebrew.zsh` - Homebrew installation and package management
  - `defaults.zsh` - macOS system preferences
  - `apps.zsh` - Runs all app install scripts

- `bin/` - Custom commands added to PATH
  - `dot` - Primary dotfiles management command

- `functions/` - Shell functions available in terminal

### Loading Order

When terminal starts (via `~/.zshrc`):
1. Sets `$DOTFILES` environment variable
2. Sources all `path.zsh` files to configure PATH
3. Sources all other `*.zsh` files (except install.zsh and completion.zsh)
4. Initializes autocomplete
5. Sources all `completion.zsh` files

### Key Configuration Files

- **Homebrew**: `apps/homebrew/Brewfile` - Defines all brew packages, casks, and Mac App Store apps
- **Git**: `apps/git/gitconfig.symlink` - Global git configuration
- **Terminal**: `apps/terminal/zshrc.symlink` - Main zsh configuration
- **Ruby**: `apps/ruby/` - rbenv and Ruby configuration

### Environment Variables

- `$DOTFILES` - Set to `~/.dotfiles`
- `$PROJECTS` - Set to `~/Documents/Code` (project directory)

## Development Notes

- All symlinks are created automatically by `scripts/terminal.zsh`
- The `dot` command should be run periodically to keep everything updated
- App-specific install scripts in `apps/*/install.zsh` are run during updates
- The repository uses zsh as the default shell