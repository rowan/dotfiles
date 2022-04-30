#add each topic folder to fpath so that they can add functions and completion scripts
for dir in $(find $DOTFILES/apps/* -type d)
do
  fpath=($dir $fpath)
done