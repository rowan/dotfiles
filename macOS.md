# Instructions for setting up a brand new Mac

0. Set the default account name based on the machine

E.g. Mini/mini, or Studio/studio

1. Update the location of the home directory created during install

- System Preferences > Users & Groups
- Click the lock to allow changes
- Right click on default user account (this should be named to match the machine - e.g. "Mini"), and select `Advanced Options...`
- Update the home directory to be `Temp`
- Restart (this will ask you to reconfig macOS settings, which you can skip)
- Using Finder, rename `/Users/[name]` to use the capitalised name
- System Preferences > Users & Groups
- Repeat the steps above to change the home directory to use the newly renamed capitalised maching name folder
- Using Finder, delete `/Users/Temp`

The home folder should now reference the capitalised version.

2. Update sharing settings

- System Preferences > Sharing
- Change the Computer Name
- Click `Edit...` to update the LAN name

Then... (optional)

- Select 'Screen Sharing' from the menu

3. Run the `dotfiles` install + update 

See [README.md]

4. Setup 1Password

- Master Password
- TouchID
- Apple Watch?
- Add Chrome extension

5. Setup Finder

- Finder > Preferences
- General > Set New Finder Window to show home directory
- Sidebar > Add home directory (can then drag and drop other folders onto the favourites in sidebar e.g. add Dropbox folders)
- Advances > Select 'Remove items from the Bin after 30 days'

6. Setup Internet Accounts

- System Preferences > Internet Accounts
- Should list all accounts linked to iCloud account as inactive
- For Google accounts, 'Mail' and 'Calendar' should be ticked (need to authenticate when selecting 'Mail')
- For iCloud accounts all options should be ticked

7. Setup Mail Preferences
- New Message Sound: None (also untick 'Play sounds for other mail actions')
- Remove Unedited Downloads: When Mail Quits
- Select 'Automatically try sending later...'
- Accounts > Download attachments: All (for each account)
- Fonts & Colors > Message: Helvetica 14, Fixed-width: Monaco 14
- Viewing > List Preview: None, also tick 'Display unread messages with bold font' and 'Use Smart Addresses'
- Composing > Send new messages from: rowan@hoku.nz

Then...

- System Preferences > Keyboard > Shortcuts
- Add a new shortcut for Mail, Menu Title: "Archive", Keyboard Shortcur Cmd-Shift-A

8. Setup Calendar Preferences:
- Select default calendar
- Unselect 'Show Birthdays Calendar' and 'Show Holidays Calendar' (these are managed via Google Calendar)
- Turn on Timezone support (under Advanced)

9. Setup Applications

- Asana
- Dropbox
- Notion
- Slack
- Zoom

Then...

Setup Accessibility permissions for Dropbox and Zoom:

- System Preferences > Security & Privacy ...
- Privacy, then allow Dropbox and Zoom
- Camera & Microphone, allow Zoom

10. Setup dev environment

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
- Setup AppleID (Xcode > Preferences > Accounts)

11. Setup `Postico`

_TO BE COMPLETED_

TODO: needs pgfav files in 1Password??

12. Setup `VS Code`

_TO BE COMPLETED_

- Install `Visual Studio Code` plugins
TODO: are these saved in a preferences file somewhere?

- Right click on Explorer and select "Open Editors" to view summary of currently open files

13. Setup `Printers`

- System Preferences > Printers & Scanners
- Press "+" and choose printers to install

14. Setup `Influx` (optional)

To backup:
`influx backup -compression gzip ./ -t [token]`

This creates a backup in the current working directory.

To restore:
`influx restore ./ -t [token] -full`

This assumes the backup files are in the current working directory.

Note: substitute [token] with an API token 

15. Setup `Plex` (optional)

_TO BE COMPLETED_