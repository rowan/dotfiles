  # Add to login items if not already there
  osascript -e '
  tell application "System Events"
      if not (exists login item "Tailscale") then
          make login item at end with properties {path:"/Applications/Tailscale.app", hidden:false}
      end if
  end tell
  '

  # Start Tailscale if not running
  if ! pgrep -q "Tailscale"; then
      open -a "Tailscale"
  fi