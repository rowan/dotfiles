# install a new environment

# if there is an error then stop immediately
set -e

# setup dotfiles
echo "▶️  Setup dotfiles"
# assumes this code is run from ~/.dotfiles
export DOTFILES=$HOME/.dotfiles
echo "DOTFILES = ${DOTFILES}"

# setup terminal
echo "▶️  Setup terminal"
source "$DOTFILES/scripts/terminal.zsh"

# prompt to reboot terminal and run update scripts
echo "✅ Initial install complete - please restart terminal and run 'dot'"