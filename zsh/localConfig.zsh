# Auto Suggestion Config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=4"
# ZSH_AUTOSUGGEST_STRATEGY=( "history" "completion" )
ZSH_AUTOSUGGEST_USE_ASYNC="ON" # [Disabled while bug https://github.com/zsh-users/zsh-autosuggestions/issues/241 is active]
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="200"
bindkey '^N' autosuggest-execute
bindkey '^K' autosuggest-next
bindkey '^J' autosuggest-previous
bindkey '^L' forward-word
bindkey '^H' backward-delete-word

# History Substring Config
setopt HIST_IGNORE_ALL_DUPS
