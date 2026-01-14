# Remote Development - SSH Auto-Attach
# Only runs when connecting via SSH

# SSH Agent persistence (for git operations)
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
fi

# Auto-attach to tmux on SSH login
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]]; then
    # Attach to existing session or start new one
    tmux attach -t dev 2>/dev/null || start-tmux
fi

# Aliases
alias tmx="start-tmux"
