# Work in emacs mode
bindkey -e

# Enable vim editing of command
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# Up and down history considering the prefix
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Navigate with ALT+ARROW
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
