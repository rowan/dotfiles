# update an existing environment

SCRIPTS=$DOTFILES/scripts

# confirm install.zsh has been run previously, and terminal has been restared
echo "▶️  Check env variables"
if export | grep DOTFILES
then
  echo "✔️ found"
else
  echo "🛑 \033[0;31mPlease run scripts/install.zsh first\033[0m"
  exit 1
fi

# setup macOS defaults
echo "▶️  Setup macOS defaults"
source "$SCRIPTS/macos-defaults.zsh"
echo "Done"


