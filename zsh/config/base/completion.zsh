# Enable autocompletion
autoload -U compinit && compinit

# Do not autoselect the first completion entry
unsetopt menu_complete

# Disable start/stop flow control characters in the editor
unsetopt flowcontrol

# Show completion menu on successive tab press
setopt auto_menu

# Set the completion ahead of the cursor
setopt complete_in_word

# Don't do partial completions, always do the full completion
setopt always_to_end

# Make completions case- and hyphen-insensitive
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# Complete '.' and '..'
zstyle ':completion:*' special-dirs true

# Start the selection unconditionally
zstyle ':completion:*:*:*:*:*' menu select

zstyle ':completion:*:*:*:*:processes' command 'ps -u '"${USERNAME}"' -o pid,user,comm -w -w'

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' '_*'

# Override the ignores in single case scenario
zstyle '*' single-ignored show

# Disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Load bash completions
autoload -U +X bashcompinit && bashcompinit

# # TODO: Enable this?
# zstyle ':completion:*' use-cache yes
# # TODO: Make this persistent?
# zstyle ':completion:*' cache-path /Users/celo/.zgen/robbyrussell/oh-my-zsh-master/cache
