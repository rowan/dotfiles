# dotfiles

Scripts to install and update a development environment.

## install

To install these dotfiles on a new environment:

1. Install XCode Command Line Tools
`xcode-select --install`

2. Clone the repository:
`git clone https://github.com/rowan/dotfiles.git ~/.dotfiles`

3. Then, run **install**:
`cd ~/.dotfiles`
`source scripts/install.zsh`

This:

- Updates macOS
- Adds **bin/** files to `$PATH`
- Symlinks **app/\*.symlink** files to `$HOME`
- Runs **app/\*\*/\*.zsh** scripts (excluding **app/\*\*/install.zsh** scripts)
- Runs **app/\*\*/path.zsh** scripts _first_ (to setup `$PATH` or similar)
- Runs **app/\*\*/completion.zsh** scripts _last_ (to setup autocompletes)
- Updates shell to `zsh`
- Installs `homebrew`
- Runs the **update** script - see below

Finally, setup the various apps and tools that are installed.

_TO BE COMPLETED_

## update 

To update an existing environment:

Use the **dot** command:

`dot`

This uses the **update** script:

`scripts/update.zsh`

This:

- Sets macOS defaults
- Runs **homebrew** (including Mac App Store usung `mas`)
- Runs **app/\*\*/install.zsh** scripts
- Updates macOS

---

To investigate:
- [`apply-user-defaults`](https://github.com/zero-sh/apply-user-defaults)
- https://github.com/mathiasbynens/dotfiles/blob/main/.macos

Broken:
- XCode command line tools need to be installed to run git the first time
- Need to accept XCode license
`sudo xcodebuild -license`
- Terminal colours are borked
- Update.zsh needs to stop and prompt for terminal restart rather than just running update script

- Bunch of Apple errors related to XCode tools being installed in two locations???
`Class AppleTypeCRetimerRestoreInfoHelper is implemented in both /usr/lib/libauthinstall.dylib (0x1ed579eb0) and /Library/Apple/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/MobileDevice (0x10a5b84f8)`
https://developer.apple.com/forums/thread/698628
https://developer.apple.com/forums/thread/670389


---

Inspired by: https://github.com/holman/dotfiles