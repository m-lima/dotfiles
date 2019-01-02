case "${pluginManager}" in
  zgen)
    if ! source "${HOME}/.zgen/zgen.zsh"
    then
      git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
      source "${HOME}/.zgen/zgen.zsh"
    fi

    if ! zgen saved
    then
      case "${zshFramework}" in
        omz)
          zgen oh-my-zsh
          zgen oh-my-zsh plugins/git

          zgen load zsh-users/zsh-syntax-highlighting
          zgen load m-lima/simpalt simpalt.zsh-theme
          ;;

        prezto)
          zgen prezto

          zgen prezto '*:*' case-sensitive 'no'
          zgen prezto '*:*' color 'yes'
          zgen prezto prompt theme 'simpalt'

          zgen prezto git
          zgen prezto syntax-highlighting
          zgen prezto history-substring-search

          zgen load m-lima/simpalt
          ;;
      esac

      zgen oh-my-zsh plugins/colorize
      zgen load m-lima/nali
      zgen load m-lima/nali-autosuggestions

      for plugin in ${localPlugins}
      do
        zgen ${(z)plugin}
      done

      zgen save
    fi
    ;;

  zplug)
    if ! source "${HOME}/.zplug/init.zsh"
    then
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
      source "${HOME}/.zplug/init.zsh"
    fi

    # zplug "lib/completion", from:oh-my-zsh
    zplug "lib/grep", from:oh-my-zsh
    zplug "lib/history", from:oh-my-zsh
    zplug "plugins/colorize", from:oh-my-zsh
    zplug "plugins/git", from:oh-my-zsh

    zplug "m-lima/nali"
    zplug "m-lima/nali-autosuggestions"
    zplug "m-lima/simpalt", as:theme
    zplug "zsh-users/zsh-syntax-highlighting"

    for plugin in ${localPlugins}
    do
      zplug ${(z)plugin}
    done

    if ! zplug check
    then
      zplug install
    fi
    ;;
esac

# Auto Suggestion Config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=4"
ZSH_AUTOSUGGEST_USE_ASYNC="ON"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="200"
bindkey '^N' autosuggest-execute
bindkey '^K' autosuggest-next
bindkey '^J' autosuggest-previous
bindkey '^L' forward-word
bindkey '^H' backward-delete-word
