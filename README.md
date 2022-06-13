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

4. Restart terminal

This should now be running with new theme and with modified path, prompt etc.

Note: initially several of the files that are run when the terminal is started will fail, as dependencies such as `yarn` and `rbenv` have not been installed yet.

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

Inspired by: https://github.com/holman/dotfiles