# install a new environment

# assumes this code is run from ~/.dotfiles
SCRIPTS=$HOME/.dotfiles/scripts

# if there is an error then stop immediately
set -e

# ask for git credentials
# update the templated gitconfig files with these credentials
echo "▶️  Setup gitconfig"
echo "🛑 \033[0;31mTO BE COMPLETED\033[0m"

# setup all of the symlinks
# first, remove the existing symlinks, so this is repeatable
echo "▶️  Install symlinks"
zsh "$SCRIPTS/symlinks.zsh"