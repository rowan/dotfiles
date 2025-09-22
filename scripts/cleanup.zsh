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

echo "› \033[00;34mCleaning up other known issues\033[0m"

# Add other one-time cleanup tasks here as needed
# For example:
# - Remove deprecated config files
# - Clean up old application support files
# - Fix permission issues

echo "✅ Cleanup complete"
echo ""
echo "Note: You may need to restart your terminal after cleanup"