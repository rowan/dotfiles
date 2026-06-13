# Sets macOS defaults

# Quit Safari so it picks up the new settings on next launch
osascript -e 'quit app "Safari"'

echo "ℹ️  Applying macOS defaults"

# Applying defaults is best-effort: a single rejected key (e.g. on a newer
# macOS) should warn, not abort the whole `dot` run under `set -e`. Save the
# caller's errexit state, disable it for the writes below, then restore it.
[[ -o errexit ]] && _errexit_was_set=1 || _errexit_was_set=
set +e

# Record any failed write so failures are surfaced in a summary at the end
# rather than scrolling past unnoticed, while the rest of the run continues.
defaults_failed=()
set_default() { defaults write "$@" || defaults_failed+=("$1 $2"); }

# Turn on app auto-update
set_default com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
set_default com.apple.commerce AutoUpdate -bool true

# Use AirDrop over every interface
set_default com.apple.NetworkBrowser BrowseAllInterfaces -int 1

# Trackpad - enable three-finger tap to look up & data detectors
set_default com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2

# Dock - show on the right, no autohide
set_default com.apple.dock orientation -string "right"
set_default com.apple.dock autohide -bool false

# Finder - don't show volumes on desktop, default to column view, empty trash securely
set_default com.apple.finder ShowHardDrivesOnDesktop -bool false
set_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
set_default com.apple.finder ShowRemovableMediaOnDesktop -bool false
set_default com.apple.finder FXPreferredViewStyle -string "clmv"
set_default com.apple.finder EmptyTrashSecurely -bool true

# Don't create .DS_Store files on network or USB volumes
set_default com.apple.desktopservices DSDontWriteNetworkStores -bool true
set_default com.apple.desktopservices DSDontWriteUSBStores -bool true

# Save files to disk (rather than iCloud) by default
set_default NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Photos - don't open automatically when devices are plugged in
set_default com.apple.ImageCapture disableHotPlug -bool true

# Calendar
set_default com.apple.iCal "TimeZone support enabled" -bool true
set_default com.apple.iCal "display birthdays calendar" -bool true
set_default com.apple.iCal "display holidays calendar" -bool true
set_default com.apple.iCal CalendarListMiniMonthVisibleMonths -int 3
set_default com.apple.iCal CalendarSidebarShown -bool true

# Safari - set up for development. Most of these write into Safari's protected
# container, which requires "Full Disk Access" for Terminal in System Settings >
# Privacy & Security > Full Disk Access; without it the writes fail.
echo "ℹ️  If Safari settings fail, grant Terminal 'Full Disk Access' in System Settings"
set_default com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
set_default com.apple.Safari AutoFillPasswords -bool false
set_default com.apple.Safari AlwaysRestoreSessionAtLaunch -int 1
set_default com.apple.Safari HomePage -string "https://hoku.nz/"
set_default com.apple.Safari IncludeDevelopMenu -bool true
set_default com.apple.Safari IncludeInternalDebugMenu -bool true
set_default com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
set_default NSGlobalDomain WebKitDeveloperExtras -bool true

# Restore the caller's errexit setting now the best-effort writes are done.
[[ -n $_errexit_was_set ]] && set -e
unset _errexit_was_set

if (( ${#defaults_failed} )); then
  echo ""
  echo "⚠️  Some defaults failed to apply:"
  for failed in "${defaults_failed[@]}"; do
    echo "   - $failed"
  done
  if [[ "${defaults_failed[*]}" == *com.apple.Safari* ]]; then
    echo "   Safari settings usually require 'Full Disk Access' for Terminal:"
    echo "   System Settings > Privacy & Security > Full Disk Access"
    echo "   Add Terminal.app, then re-run 'dot'"
  fi
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