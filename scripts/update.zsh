# update an existing environment

# confirm install.zsh has been run previously, and terminal has been restared
if export | grep DOTFILES
then
  echo "Updating..."
else
  echo "🛑 \033[0;31mPlease run scripts/install.zsh first\033[0m"
  exit 1
fi

