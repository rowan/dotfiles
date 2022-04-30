# first, populate gitconfig.symlink with credentials

GIT=$DOTFILES/apps/git

# remove the existing file, so this is repeatable
rm -f $GIT/gitconfig.symlink

# ask for github user details
vared -c -p "✋ What is your github account username? " git_authorname
vared -c -p "✋ What is your github account email? " git_authoremail

# create the symlink from the example file
sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" $GIT/gitconfig.symlink.example > $GIT/gitconfig.symlink

echo "Created \033[00;34m${GIT}/gitconfig.symlink\033[0m"

# update symlinks in $HOME directory
# first, remove the existing symlinks, so this is repeatable
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

# create themes
# see: https://github.com/tomislav/osx-terminal.app-colors-solarized

# remove any existing defaults
/usr/libexec/PlistBuddy -c "Delete :Window\ Settings:Solarized\ Light" ~/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -c "Delete :Window\ Settings:Solarized\ Dark" ~/Library/Preferences/com.apple.Terminal.plist

# add new defaults
cp $DOTFILES/apps/terminal/Solarized\ Light.terminal light-theme.plist
/usr/libexec/PlistBuddy -c "Add ':Window Settings:Solarized Light' dict" ~/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -c "Merge 'light-theme.plist' ':Window Settings:Solarized Light'" ~/Library/Preferences/com.apple.Terminal.plist
rm light-theme.plist
echo "Added \033[00;34mSolarized Light\033[0m theme"

cp $DOTFILES/apps/terminal/Solarized\ Dark.terminal dark-theme.plist
/usr/libexec/PlistBuddy -c "Add ':Window Settings:Solarized Dark' dict" ~/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -c "Merge 'dark-theme.plist' ':Window Settings:Solarized Dark'" ~/Library/Preferences/com.apple.Terminal.plist
rm dark-theme.plist
echo "Added \033[00;34mSolarized Dark\033[0m theme"

# set default theme
defaults write com.apple.terminal "Default Window Settings" -string "Solarized Dark"
defaults write com.apple.Terminal "Startup Window Settings" -string "Solarized Dark"
echo "Set \033[00;34mSolarized Dark\033[0m to be default theme"
echo "Please restart the terminal to apply this theme"