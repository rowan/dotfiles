# install a new environment

# assumes this code is run from ~/.dotfiles
export DOTFILES=$HOME/.dotfiles

SCRIPTS=$DOTFILES/scripts

# if there is an error then stop immediately
set -e

# run macOS updates
echo "▶️  Update macOS"
sudo softwareupdate -i -a

# ask for git credentials
# update the templated gitconfig files with these credentials
echo "▶️  Setup gitconfig"
source "$SCRIPTS/gitconfig.zsh"

# setup all of the symlinks
# first, remove the existing symlinks, so this is repeatable
echo "▶️  Install symlinks"
source "$SCRIPTS/symlinks.zsh"

# run the update script
source "$SCRIPTS/update.zsh"