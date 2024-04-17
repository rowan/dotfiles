# install a new environment

# if there is an error then stop immediately
set -e

# setup dotfiles
echo "▶️  Setup dotfiles"
# assumes this code is run from ~/.dotfiles
export DOTFILES=$HOME/.dotfiles
echo "DOTFILES = ${DOTFILES}"

# install rosetta
echo "▶️  Install rosetta"
softwareupdate --install-rosetta --agree-to-license

# setup terminal
echo "▶️  Setup terminal"
source "$DOTFILES/scripts/terminal.zsh"

# setup full disk access for terminal
echo "Please enable 'Full Disk Access' permission for Terminal in System Preferences"
# open "x-apple.systempreferences:com.apple.preference.security?Privacy"

# prompt to reboot terminal and run update scripts
echo "✅ Initial install complete - please restart terminal and run 'dot'"
