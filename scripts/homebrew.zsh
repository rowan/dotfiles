if [[ $(command -v brew) == "" ]]
then
    echo "Installing brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is installed"
    echo $(which brew)
fi

echo "› \033[00;34mbrew update\033[0m"
brew update

echo "› \033[00;34mbrew bundle\033[0m"
brew bundle --file $DOTFILES/apps/homebrew/Brewfile --mas
# Only run Xcode first-launch setup if full Xcode.app is installed
if command -v xcodebuild &>/dev/null && [[ -d "/Applications/Xcode.app" ]]; then
    echo "› \033[00;34msudo xcodebuild -runFirstLaunch\033[0m"
    sudo xcodebuild -runFirstLaunch
fi