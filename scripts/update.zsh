# update an existing environment

APPS=$DOTFILES/apps
SCRIPTS=$DOTFILES/scripts

# if there is an error then stop immediately
set -e

# confirm install.zsh has been run previously, and terminal has been restared
echo "▶️  Confirm install"
if export | grep DOTFILES
then
  echo "Done"
else
  echo "🛑 \033[0;31mPlease run scripts/install.zsh and restart the terminal first\033[0m"
  exit 1
fi

# setup macOS defaults
echo "▶️  Setup macOS defaults"
source "$SCRIPTS/macos-defaults.zsh"
echo "Done"

# update homebrew (install if missing) + run brew bundle
echo "▶️  Update homebrew"
source "$DOTFILES/scripts/homebrew.zsh"
echo "Done"

# run install scripts
echo "▶️  Run install scripts"
for file in $(find $APPS -name "install.zsh")
do
  echo "› \033[00;34m${file}\033[0m"
  source $file
done
echo "Done"

# run macOS updates
echo "▶️  Update macOS"
sudo softwareupdate -i -a
echo "Done"

# and... we're done!
echo "✅ All up-to-date"