# setup github
gh auth login -h github.com -p https -w

# setup ruby 
rbenv install -l
vared -c -p "✋ What version of ruby to install? " ruby_version
rbenv install $ruby_version
rbenv global $ruby_version

# start postgres
brew services start postgresql

# RowanWeb

if [ ! -d "$PROJECTS/RowanWeb" ]
then
    git clone https://github.com/HokuNZ/RowanWeb.git $PROJECTS/RowanWeb/
    p RowanWeb
    npm i
    github $PROJECTS/RowanWeb/
else
    echo "$fg[blue]RowanWeb$reset_color already exists"
fi

# HokuWeb

if [ ! -d "$PROJECTS/HokuWeb" ]
then
    git clone https://github.com/HokuNZ/HokuWeb.git $PROJECTS/HokuWeb/
    p HokuWeb
    github $PROJECTS/HokuWeb/
else
    echo "$fg[blue]HokuWeb$reset_color already exists"
fi

# Hive

if [ ! -d "$PROJECTS/Hive" ]
then
    git clone https://github.com/HokuNZ/Hive.git $PROJECTS/Hive/
    p Hive
    rbenv install
    gem install bundler
    bundle install
    yarn
    vared -c -p "✋ What is the %{$fg_bold[white]%}development%{$reset_color%} master key for Hive (look in 1Password)? " hive_dev_key
    echo $hive_dev_key > config/credentials/development.key
    vared -c -p "✋ What is the %{$fg_bold[white]%}test%{$reset_color%} master key for Hive (look in 1Password)? " hive_test_key
    echo $hive_test_key > config/credentials/test.key
    gem install rails
    rails db:setup
    github $PROJECTS/Hive/
else
    echo "$fg[blue]Hive$reset_color already exists"
fi


# Dash

if [ ! -d "$PROJECTS/Dash" ]
then
    git clone https://github.com/HokuNZ/Dash.git $PROJECTS/Dash/
    p Dash
    rbenv install
    gem install bundler
    bundle install
    yarn
    vared -c -p "✋ What is the %{$fg_bold[white]%}development%{$reset_color%} master key for Dash (look in 1Password)? " dash_dev_key
    echo $dash_dev_key > config/credentials/development.key
    vared -c -p "✋ What is the %{$fg_bold[white]%}test%{$reset_color%} master key for Dash (look in 1Password)? " dash_test_key
    echo $dash_test_key > config/credentials/test.key
    gem install rails
    rails db:setup
    github $PROJECTS/Dash/
else
    echo "$fg[blue]Dash$reset_color already exists"
fi

# TraigeWeb

if [ ! -d "$PROJECTS/TriageWeb" ]
then
    git clone https://github.com/HokuNZ/TriageWeb.git $PROJECTS/TriageWeb/
    p TriageWeb
    npm i
    github $PROJECTS/TriageWeb/
else
    echo "$fg[blue]TriageWeb$reset_color already exists"
fi

# Money Wings 

if [ ! -d "$PROJECTS/MoneyWings" ]
then
    git clone https://github.com/HokuNZ/MoneyWings.git $PROJECTS/MoneyWings/
    p MoneyWings
    rbenv install
    gem install bundler
    bundle install
    yarn
    vared -c -p "✋ What is the %{$fg_bold[white]%}development%{$reset_color%} master key for Money Wings (look in 1Password)? " money_wings_dev_key
    echo $money_wings_dev_key > config/credentials/development.key
    vared -c -p "✋ What is the %{$fg_bold[white]%}test%{$reset_color%} master key for Money Wings (look in 1Password)? " money_wings_test_key
    echo $money_wings_test_key > config/credentials/test.key
    gem install rails
    rails db:setup
    github $PROJECTS/MoneyWings/
else
    echo "$fg[blue]MoneyWings$reset_color already exists"
fi

# MailTriage
if [ ! -d "$PROJECTS/MailTriage" ]
then
    git clone https://github.com/HokuNZ/MailTriage.git $PROJECTS/MailTriage/
    p MailTriage
    gem install bundler
    bundle install
    github $PROJECTS/MailTriage/
    open MailTriage.xcodeproj
else
    echo "$fg[blue]MailTriage$reset_color already exists"
fi

# HoddyRoad
if [ ! -d "$PROJECTS/HoddyRoad" ]
then
    git clone https://github.com/HokuNZ/HoddyRoad.git $PROJECTS/HoddyRoad/
    p HoddyRoad
    # gem install bundler
    # bundle install
    github $PROJECTS/HoddyRoad/
    open HoddyRoad.xcodeproj
else
    echo "$fg[blue]HoddyRoad$reset_color already exists"
fi

# HoddyRoadAPI
if [ ! -d "$PROJECTS/HoddyRoadAPI" ]
then
    git clone https://github.com/HokuNZ/HoddyRoadAPI.git $PROJECTS/HoddyRoadAPI/
    p HoddyRoadAPI
    gem install bundler
    bundle install
    vared -c -p "✋ What is the %{$fg_bold[white]%}development%{$reset_color%} master key for HoddyRoadAPI (look in 1Password)? " hoddy_api_dev_key
    echo $hoddy_api_dev_key > config/credentials/development.key
    vared -c -p "✋ What is the %{$fg_bold[white]%}test%{$reset_color%} master key for HoddyRoadAPI (look in 1Password)? " hoddy_api_test_key
    echo $hoddy_api_test_key > config/credentials/test.key
    gem install rails
    rails db:setup
    github $PROJECTS/HoddyRoadAPI/
else
    echo "$fg[blue]HoddyRoadAPI$reset_color already exists"
fi

cd $DOTFILES