# Instructions for setting up a brand new Mac

0. Set the default account name based on the machine

E.g. Mini/mini, or Studio/studio

1. Update the location of the home directory created during install

- System Preferences > Users & Groups
- Click the lock to allow changes
- Right click on default user account (this should be named to match the machine - e.g. "Mini"), and select `Advanced Options...`
- Update the home directory to use the capitalised name
- Restart
- Using Finder, rename the /User directory to use the capitalised name
- Restart

The home folder should now reference the capitalised version.

1b. Update the shared name of the computer

- System Preferences > Sharing
- Change the Computer Name
- Click `Edit...` to update the LAN name

2. Run the `dotfiles` install + update 

See [README.md]

3. Setup 1Password

4. Setup Dropbox

5. Setup team apps

- Asana
- Notion
- Slack
- Zoom

6. Setup dev environment

- Open `Github Desktop`
- Sign in

Then...

- Run `source $DOTFILES/scripts/code.zsh`

or...

- Clone repositories into `~/Documents/Code`

For hugo applications...

For rails applications...

For xcode applications...

- Setup `Postico`
TODO: needs pgfav files in 1Password??
- Install `Visual Studio Code` plugins
TODO: are these saved in a preferences file somewhere?

7. (Optional) Setup `Influx`

To backup:
`influx backup -compression gzip ./ -t [token]`

This creates a backup in the current working directory.

To restore:
`influx restore ./ -t [token] -full`

This assumes the backup files are in the current working directory.

Note: substitute [token] with an API token 

8. (Optional) Setup Plex server??
