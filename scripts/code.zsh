# setup github
gh auth login -h github.com -p https -w

# setup ruby 
rbenv install -l
vared -c -p "✋ What version of ruby to install? " ruby_version
rbenv install $ruby_version
rbenv global $ruby_version

# RowanWeb

if [ ! -d "$PROJECTS/RowanWeb" ]
then
    git clone https://github.com/HokuNZ/RowanWeb.git $PROJECTS/RowanWeb/
    p RowanWeb
    npm i
else
    echo "\033[00;34mRowanWeb\033[0m already exists"
fi

# Hive

if [ ! -d "$PROJECTS/Hive" ]
then
    git clone https://github.com/HokuNZ/Hive.git $PROJECTS/Hive/
    p Hive
    rbenv install
    # gem install bundler
    bundle install
    yarn
    gem install rails
    rails db:setup
    github $PROJECTS/Hive/
else
    echo "\033[00;34mHive\033[0m already exists"
fi

cd $DOTFILES