# Auto Suggestion Config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=4"
# ZSH_AUTOSUGGEST_USE_ASYNC="ON"  [Disabled while bug https://github.com/zsh-users/zsh-autosuggestions/issues/241 is active]
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="200"
bindkey '^J' autosuggest-execute
bindkey '^F' forward-word

# History Substring Config
setopt HIST_IGNORE_ALL_DUPS
