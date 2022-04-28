/usr/libexec/PlistBuddy -c "Delete :Window\ Settings:Solarised\ Dark" ~/Library/Preferences/com.apple.Terminal.plist 
# /usr/libexec/PlistBuddy -c "Import Window\ Settings:Solarised\ Dark ~/.dotfiles/apps/terminal/Soalrised\ Dark\ Theme.plist" ~/Library/Preferences/com.apple.Terminal.plist
# /usr/libexec/PlistBuddy -c "Import :Window\ Settings:Solarised\ Dark ~/.dotfiles/apps/terminal/Solarized\ Dark.terminal" ~/Library/Preferences/com.apple.Terminal.plist
# /usr/libexec/PlistBuddy -c -x "Print :Default\ Window\ Settings" ~/Library/Preferences/com.apple.Terminal.plist
# defaults read com.apple.Terminal "Window Settings"

# /usr/libexec/PlistBuddy -c "Print" ~/.dotfiles/apps/terminal/SolarisedDarkTheme.plist
/usr/libexec/PlistBuddy -c "Add :Window\ Settings:Solarised\ Dark dict" ~/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -c "Merge '/Users/Mini/.dotfiles/apps/terminal/SolarisedDarkTheme.plist' :Window\ Settings:Solarised\ Dark" ~/Library/Preferences/com.apple.Terminal.plist

/usr/libexec/PlistBuddy -x -c "Print :Window\ Settings:Solarised\ Dark" ~/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -x -c "Print" ~/Library/Preferences/com.apple.Terminal.plist