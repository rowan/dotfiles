# Instructions for setting up a brand new Mac

0. Set the default account name based on the machine

E.g. Mini/mini, or Studio/studio

1. Update the location of the home directory created during install

- System Settings > Users & Groups
- Right click on default user account (this should be named to match the machine - e.g. "Mini"), and select `Advanced Options...`
- Enter password to allow changes
- Update the home directory to be `Temp`
- Restart (this will ask you to reconfig macOS settings, which you can skip)
- Using Finder, rename `/Users/[name]` to use the capitalised name
- System Preferences > Users & Groups
- Repeat the steps above to change the home directory to use the newly renamed capitalised maching name folder
- Using Finder, delete `/Users/Temp`

The home folder should now reference the capitalised version.

2. Update sharing settings

- System Settings > Sharing
- Change the Computer Name
- Click `Edit...` to update the LAN name

Then... (optional)

- Select "Screen Sharing" from the menu

3. Run the `dotfiles` install + update 

See [README.md]

4. Check iCloud settings

- System Settings > AppleID > iCloud
- Under "Apps using iCloud" ...
- Confirm Photos, Contact, Calendars, Reminders and Find My Mac are all turned on

5. Setup 1Password

- Open 1Password app
- Choose the correct Hoku Group account and enter master password
- Follow instructions to install Safari browser extension
- Settings > Security, to add Touch ID unlock

6. Setup Dropbox

- Open Dropbox app
- Click the "Turn On Accessibility" button on the pop-up window
- Sign-in to Hoku account (use email address + password, rather than Google login button)
- Choose "Available offline" for sync storage
- Sign-in to personal account
- Choose "Available offline" for sync storage
- Setup Selective Sync (optional)
  
7. Setup Finder

- Finder > Settings
- General > Set New Finder Window to show home directory
- Sidebar > Add home directory (can then drag and drop other folders onto the favourites in sidebar e.g. add Dropbox folders)
- Advances > Select 'Remove items from the Bin after 30 days'

8. Setup Internet Accounts

- System Settings > Internet Accounts
- Should list all accounts linked to iCloud account as inactive
- For Google accounts, 'Mail' and 'Calendar' should be ticked (need to authenticate when selecting 'Mail')
- For iCloud accounts all options should be ticked

9. Setup Mail
   
- Mail > Settings...
- New Message Sound: None (also untick 'Play sounds for other mail actions')
- Remove Unedited Downloads: When Mail Quits
- Select 'Automatically try sending later...'
- Accounts > Download attachments: All (for each account)
- Fonts & Colors > Message: Helvetica 14, Fixed-width: Monaco 14
- Viewing > List Preview: None, also tick 'Display unread messages with bold font' and 'Use Smart Addresses'
- Composing > Send new messages from: rowan@hoku.nz

Then...

- System Settings > Keyboard > Shortcuts
- Add a new shortcut for Mail, Menu Title: "Archive", Keyboard Shortcur Cmd-Shift-A

Then...

- Import Trade Me + Xero mbox archives
(these are currently on the NAS: Backup/Laptop/Laptop 2013-12-21 17.45/Public/Keep/Import)

_TODO: ADD BETTER INSTRUCTIONS FOR THIS IMPORT_
_TODO: THESE FILES SHOULD BE KEPT SOMEWHERE MORE OBVIOUS/SAFER_

10. Setup Calendar Preferences

- Select default calendar
- Unselect 'Show Birthdays Calendar' and 'Show Holidays Calendar' (these are managed via Google Calendar)
- Turn on Timezone support (under Advanced)

11. Setup Chrome browser

- Open Chrome - don't set as default!
- Add a new user profile (click on the profile icon in toolbar, and choose add profile)
- Sign into Google account
- Setup sync, to install extensions etc
- Delete the default user profile

12. Setup Applications

- Asana
- Loom
- Notion
- Slack
- Zoom

Then...

Setup Accessibility permissions for Dropbox and Zoom:

- System Settings > Security & Privacy ...
- Privacy, then allow Dropbox and Zoom
- Camera & Microphone, allow Loom and Zoom
- Screen Recording, allow Loom, Slack and Zoom

Then...

- System Settings > Login items
- Delete Loom

13. Install Microsoft Office

- Login at microsoft.com
- Services & Subscriptions > Office
- Install
  
13. Other settings

- System Settings > Bluetooth, then disable auto-connect for AirPods (click the 'i' next to select item, then 'When last connected')

14. Setup dev environment

- Open `Github Desktop`
- Sign in

Then...

- Run `source $DOTFILES/scripts/code.zsh`

or...

- Clone repositories into `~/Documents/Code`

For hugo applications...

- Run `hugo server -D` to start local server

For rails applications...

- Run `bundle`
- Run `dev` to start local server

For xcode applications...
_TO BE COMPLETED_
- Config Xcode to open using Rosetta?
- Setup AppleID (Xcode > Settings > Accounts)

15. Setup Postico

- Import favourites from ~/.dotfiles/apps/postico

16. Setup VS Code

- Code > Settings > Turn on settings sync
- Sign in with Github, this will sync settings and extensions across devices

17. Setup Printers

- System Settings > Printers & Scanners
- Press "+" and choose printers to install

18. Setup Influx (optional)

To backup:
`influx backup -compression gzip ./ -t [token]`

This creates a backup in the current working directory.

To restore:
`influx restore ./ -t [token] -full`

This assumes the backup files are in the current working directory.

Note: substitute [token] with an API token 

19. Setup Plex (optional)

_TO BE COMPLETED_
