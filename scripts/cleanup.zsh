#!/bin/zsh
#
# One-time cleanup script for fixing environment issues
# Run this manually when needed: source scripts/cleanup.zsh
#

echo "▶️  Running one-time cleanup tasks"

# Clean up deprecated Homebrew taps
echo "› \033[00;34mCleaning up deprecated Homebrew taps\033[0m"
brew untap homebrew/homebrew-cask-drivers 2>/dev/null || true
brew untap homebrew/cask-drivers 2>/dev/null || true

# apply-user-defaults (zero-sh/tap) was replaced by plain `defaults write`
# calls in scripts/defaults.zsh. Uninstall the formula before untapping, or
# brew refuses to drop a tap that still has installed formulae.
if brew list --formula apply-user-defaults &>/dev/null; then
    echo "  Uninstalling apply-user-defaults"
    brew uninstall --force apply-user-defaults 2>/dev/null || true
fi
brew untap zero-sh/tap 2>/dev/null || true

# Clean up casks that have been removed from Brewfile
echo "› \033[00;34mCleaning up removed casks\033[0m"

REMOVED_CASKS=(
    "asana"
    "calibre"
)

for cask in "${REMOVED_CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "  Uninstalling $cask"
        brew uninstall --cask --force "$cask" 2>/dev/null || true
    fi
done

# Clean up Mac App Store apps that have been moved to cask
echo "› \033[00;34mCleaning up MAS apps moved to cask\033[0m"

MAS_TO_CASK_APPS=(
    "DaisyDisk:411643860"
    "Mp3tag:1532597159"
    "Postico:1031280567"
    "Slack:803453959"
)

for app_entry in "${MAS_TO_CASK_APPS[@]}"; do
    app_name="${app_entry%%:*}"
    app_id="${app_entry##*:}"
    if mas list | grep -q "$app_id"; then
        echo "  Uninstalling MAS version of $app_name (id: $app_id)"
        mas uninstall "$app_id" 2>/dev/null || true
    fi
done

echo "› \033[00;34mCleaning up other known issues\033[0m"

# Add other one-time cleanup tasks here as needed
# For example:
# - Remove deprecated config files
# - Clean up old application support files
# - Fix permission issues

# Empty the trash (with confirmation - this permanently deletes files)
echo "› \033[00;34mTrash cleanup\033[0m"
read "?  Empty the Trash? This permanently deletes files. [y/N] " empty_trash
if [[ "$empty_trash" =~ ^[Yy]$ ]]; then
    osascript -e 'tell application "Finder" to empty trash' 2>/dev/null || true
else
    echo "  Skipping - empty manually from Finder if needed"
fi

echo "✅ Cleanup complete"
echo ""
echo "Note: You may need to restart your terminal after cleanup"