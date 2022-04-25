# increase the maximum number of file descriptiors
sudo cp ~/.dotfiles/apps/influx/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist

# restart the service
brew services restart influxdb