# Add to login items if not already there
osascript -e '
tell application "System Events"
    if not (exists login item "Amphetamine") then
        make login item at end with properties {path:"/Applications/Amphetamine.app", hidden:false}
    end if
end tell
'

# Start Amphetamine if not running
if ! pgrep -q "Amphetamine"; then
    open -a "Amphetamine"
fi
