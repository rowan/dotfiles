# asks for github user details and generates /git/gitconfig.local.symlink

GIT=$DOTFILES/apps/git

# first, remove the existing file (in case we are running this a second time)
rm -f $GIT/gitconfig.local.symlink

# ask for github user details
vared -c -p "✋ What is your github account username? " git_authorname
vared -c -p "✋ What is your github account email? " git_authoremail

# create the symlink from the example file
sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" $GIT/gitconfig.local.symlink.example > $GIT/gitconfig.local.symlink

echo "Created \033[00;34m${GIT}/gitconfig.local.symlink\033[0m"