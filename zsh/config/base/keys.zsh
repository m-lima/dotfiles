# Enable vim editing of command
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line