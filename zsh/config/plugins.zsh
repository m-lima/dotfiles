source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved
then
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/git

  zgen load m-lima/nali
  zgen load m-lima/nali-autosuggestions
  zgen load m-lima/simpalt simpalt.zsh-theme
  zgen load zsh-users/zsh-syntax-highlighting

  for plugin in ${localPlugins}
  do
    zgen load ${plugin}
  done

  zgen save
fi

# Auto Suggestion Config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=4"
ZSH_AUTOSUGGEST_USE_ASYNC="ON"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="200"
bindkey '^N' autosuggest-execute
bindkey '^K' autosuggest-next
bindkey '^J' autosuggest-previous
bindkey '^L' forward-word
bindkey '^H' backward-delete-word

