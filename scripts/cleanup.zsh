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

# Clean up Docker conflicts
echo "› \033[00;34mCleaning up Docker conflicts\033[0m"

# Remove old Docker symlinks that can conflict with installations
DOCKER_SYMLINKS=(
    "/usr/local/bin/hub-tool"
    "/usr/local/bin/docker"
    "/usr/local/bin/docker-compose"
    "/usr/local/bin/docker-credential-desktop"
    "/usr/local/bin/docker-credential-ecr-login"
    "/usr/local/bin/docker-credential-osxkeychain"
    "/usr/local/bin/hyperkit"
    "/usr/local/bin/kubectl.docker"
    "/usr/local/bin/kubectl"
    "/usr/local/bin/notary"
    "/usr/local/bin/vpnkit"
)

for symlink in "${DOCKER_SYMLINKS[@]}"; do
    if [ -L "$symlink" ] && [[ $(readlink "$symlink") == *"Docker.app"* ]]; then
        echo "  Removing Docker symlink: $symlink"
        sudo rm -f "$symlink" 2>/dev/null || true
    fi
done

# Uninstall docker-desktop if present (since we're not using Docker)
if brew list --cask docker-desktop &>/dev/null; then
    echo "  Uninstalling docker-desktop cask"
    brew uninstall --cask --force docker-desktop 2>/dev/null || true
fi

# Uninstall docker if present
if brew list --cask docker &>/dev/null; then
    echo "  Uninstalling docker cask"
    brew uninstall --cask --force docker 2>/dev/null || true
fi

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

# Empty the trash
echo "› \033[00;34mEmptying trash\033[0m"
osascript -e 'tell application "Finder" to empty trash' 2>/dev/null || true

echo "✅ Cleanup complete"
echo ""
echo "Note: You may need to restart your terminal after cleanup"