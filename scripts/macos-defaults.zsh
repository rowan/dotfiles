# Sets macOS defaults.
apply-user-defaults apps/system/user-defaults.yaml --verbose

killall Dock
killall Finder
killall Safari
open -a Safari