# increase the maximum number of file descriptors
command -v influxd &>/dev/null || return 0

sudo cp $DOTFILES/apps/influx/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl unload /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist

# Note: influxdb formula no longer provides a brew service.
# Start manually with: influxd
# Or create a custom launchd plist if needed.