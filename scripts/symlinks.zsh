# updates symlinks in $HOME directory

APPS=$DOTFILES/apps

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