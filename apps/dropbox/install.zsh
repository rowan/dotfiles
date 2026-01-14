# Add to login items if not already there
osascript -e '
tell application "System Events"
    if not (exists login item "Dropbox") then
        make login item at end with properties {path:"/Applications/Dropbox.app", hidden:false}
    end if
end tell
'

# Start Dropbox if not running
if ! pgrep -q "Dropbox"; then
    open -a "Dropbox"
fi
