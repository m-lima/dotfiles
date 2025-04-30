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
## Added for mac
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Navigation consistency between mac/linux
bindkey "^[[1~" beginning-of-line
bindkey "^[[2~" overwrite-mode
bindkey "^[[200~" bracketed-paste
bindkey "^[[3~" delete-char
bindkey "^[[3;5~" kill-word
bindkey "^[[4~" end-of-line
bindkey "^[[5~" beginning-of-buffer-or-history
bindkey "^[[6~" end-of-buffer-or-history

# Navigate with ALT+ARROW
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Insert previous word
bindkey "^[m" copy-prev-shell-word
