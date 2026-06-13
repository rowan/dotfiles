# Sets macOS defaults

# Kill apps we're about to reconfigure
osascript -e 'quit app "Safari"'

echo "ℹ️  Applying macOS defaults"

# Applying defaults is best-effort: a single rejected key (e.g. on a newer
# macOS) should warn, not abort the whole `dot` run under `set -e`. Save the
# caller's errexit state, disable it for the writes below, then restore it.
[[ -o errexit ]] && _errexit_was_set=1 || _errexit_was_set=
set +e

# Turn on app auto-update
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.commerce AutoUpdate -bool true

# Use AirDrop over every interface
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -int 1

# Trackpad - enable three-finger tap to look up & data detectors
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2

# Dock - show on the right, no autohide
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool false

# Finder - don't show volumes on desktop, default to column view, empty trash securely
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Don't create .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Save files to disk (rather than iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Photos - don't open automatically when devices are plugged in
defaults write com.apple.ImageCapture disableHotPlug -bool true

# Calendar
defaults write com.apple.iCal "TimeZone support enabled" -bool true
defaults write com.apple.iCal "display birthdays calendar" -bool true
defaults write com.apple.iCal "display holidays calendar" -bool true
defaults write com.apple.iCal CalendarListMiniMonthVisibleMonths -int 3
defaults write com.apple.iCal CalendarSidebarShown -bool true

# Safari - set up for development. Most of these write into Safari's protected
# container, which requires "Full Disk Access" for Terminal in System Settings >
# Privacy & Security > Full Disk Access; without it the writes fail. Track that
# separately so we can point at the likely fix (any error output shows above).
echo "ℹ️  If Safari settings fail, grant Terminal 'Full Disk Access' in System Settings"
safari_ok=true
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true || safari_ok=false
defaults write com.apple.Safari AutoFillPasswords -bool false || safari_ok=false
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -int 1 || safari_ok=false
defaults write com.apple.Safari HomePage -string "https://hoku.nz/" || safari_ok=false
defaults write com.apple.Safari IncludeDevelopMenu -bool true || safari_ok=false
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true || safari_ok=false
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true || safari_ok=false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true || safari_ok=false
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true || safari_ok=false

# Restore the caller's errexit setting now the best-effort writes are done.
[[ -n $_errexit_was_set ]] && set -e
unset _errexit_was_set

if [[ "$safari_ok" != true ]]; then
  echo ""
  echo "⚠️  Some Safari defaults failed to apply (see errors above)."
  echo "   Safari settings usually require 'Full Disk Access' for Terminal:"
  echo "   System Settings > Privacy & Security > Full Disk Access"
  echo "   Add Terminal.app, then re-run 'dot'"
  echo ""
fi

# Populate dock
# note: first item below resets existing array settings, others are added to the array

if [[ -d "/System/Applications/Launchpad.app" ]]; then
  # Include Launchpad where available (removed in macOS 26+)
  defaults write com.apple.dock persistent-apps -array '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Launchpad.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
else
  # No Launchpad - start with Safari
  defaults write com.apple.dock persistent-apps -array '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
fi
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Contacts.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Calendar.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Messages.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Notion.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Claude.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Termius.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/GitHub Desktop.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Postico 2.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Canva.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/1Password.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Utilities/Activity Monitor.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Reset
killall Dock
killall Finder
killall Calendar 2>/dev/null || true

open -a Safari