HISTSIZE=100000
SAVEHIST=100000

# Use system lock for the history instead of zsh's adhoc one
setopt hist_fcntl_lock

# Record timestamp of command in HISTFILE
setopt extended_history

# Delete duplicates first when size is reached
setopt hist_expire_dups_first

# Ignore duplicates
setopt hist_ignore_all_dups

# Don't save to history if starting with a space
setopt hist_ignore_space

# When reloading from history, don't just run it, but update the buffer
setopt hist_verify

# Share history across sessions
setopt share_history
