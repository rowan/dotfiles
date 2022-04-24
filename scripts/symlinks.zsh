# updates symlinks in $HOME directory

# assumes this code is run from ~/.dotfiles
APPS=$HOME/.dotfiles/apps

for file in $(find -H $APPS -name "*.symlink")
do
  # echo $file
  to_file="$HOME/.$(basename "${file%.*}")"

  # remove existing symlink
  rm -rf "$to_file"

  # add new symlink
  ln -s "$file" "$to_file"

  echo "Linked \033[00;34m$file\033[0m to \033[00;34m$to_file\033[0m"
done




# lrwxr-xr-x   1 mini  staff     40 22 Apr 19:08 .gemrc -> /Users/Mini/.dotfiles/ruby/gemrc.symlink
# lrwxr-xr-x   1 mini  staff     43 22 Apr 19:08 .gitconfig -> /Users/Mini/.dotfiles/git/gitconfig.symlink
# lrwxr-xr-x   1 mini  staff     49 22 Apr 19:08 .gitconfig.local -> /Users/Mini/.dotfiles/git/gitconfig.local.symlink
# lrwxr-xr-x   1 mini  staff     43 22 Apr 19:08 .gitignore -> /Users/Mini/.dotfiles/git/gitignore.symlink
# lrwxr-xr-x   1 mini  staff     40 22 Apr 19:08 .irbrc -> /Users/Mini/.dotfiles/ruby/irbrc.symlink
# lrwxr-xr-x   1 mini  staff     39 22 Apr 19:08 .zshrc -> /Users/Mini/.dotfiles/zsh/zshrc.symlink
