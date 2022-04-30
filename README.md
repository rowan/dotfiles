# dotfiles

Scripts to install and update a development environment.

## install

To install these dotfiles on a new environment:

1. Install XCode Command Line Tools
`xcode-select --version` shows the currently installed version
`xcode-select --install`

2. Clone the repository:
`git clone https://github.com/rowan/dotfiles.git ~/.dotfiles`

3. Then, run **install**:
`cd ~/.dotfiles`
`source scripts/install.zsh`

This:
- Creates a `$DOTFILES` environment variable
- Configures terminal (see: `/scripts/terminal.zsh`)
- Installs homebrew (see: `/scripts/homebrew.zsh`)

The terminal configuration:
- Adds **bin/** files to `$PATH` (see: `/apps/system/path.zsh`)
- Symlinks **app/\*.symlink** files to `$HOME`
- Runs **app/\*\*/\*.zsh** scripts in order (see `/apps/termainal/zshrc.symlink` for details):
    - First, runs **app/\*\*/path.zsh** scripts (to setup `$PATH` or similar)
    - Then, runs all other **app/\*\*/\*.zsh** scripts (excluding **install.zsh** or **completion.zsh**)
    - Finally, runs **app/\*\*/completion.zsh** scripts (to setup autocompletes)

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
- Need to accept XCode license
`sudo xcodebuild -license`
- Bunch of Apple errors related to XCode tools being installed in two locations???
`Class AppleTypeCRetimerRestoreInfoHelper is implemented in both /usr/lib/libauthinstall.dylib (0x1ed579eb0) and /Library/Apple/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/MobileDevice (0x10a5b84f8)`
https://developer.apple.com/forums/thread/698628
https://developer.apple.com/forums/thread/670389


---

Inspired by: https://github.com/holman/dotfiles