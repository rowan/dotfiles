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

<!-- - All **bin/** files are added to `$PATH` -->
- Any **app/\*.symlink** files are symlinked to `$HOME`
- Any **app/\*.zsh** files are loaded into the environment (excluding **app/install.zsh** files)
- Any **app/path.zsh** files are loaded _first_ and setup `$PATH` or similar
- Any **app/completion.zsh** files are loaded _last_ and setup autocompletes

Finally, setup the various apps and tools that are installed.

_TO BE COMPLETED_

## update 

To update an existing environment:

Use the **dot** command:

`dot`

This uses the **update** script:

`scripts/update.zsh`