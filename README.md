# dotfiles

Scripts to install and update a development environment.

## install

To install these dotfiles on a new environment:

First, clone the repository:

```
zsh
git clone https://github.com/rowan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then, run **install**:

`scripts/install.zsh`

This:

- Updates macOS
- Adds **bin/** files to `$PATH`
- Symlinks **app/\*.symlink** files to `$HOME`
- Runs **app/\*\*/\*.zsh** scripts (excluding **app/\*\*/install.zsh** scripts)
- Runs **app/\*\*/path.zsh** scripts _first_ (to setup `$PATH` or similar)
- Runs **app/\*\*/completion.zsh** scripts _last_ (to setup autocompletes)
- Updates shell to `zsh`
- Installs `homebrew`

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

Inspired by: https://github.com/holman/dotfiles