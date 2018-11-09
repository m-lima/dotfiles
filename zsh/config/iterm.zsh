  source "${HOME}/.iterm2_shell_integration.zsh"

  function buildGitStatusLabel {
    _STATUS=""

    # check status of files
    _INDEX=$(command git status --porcelain 2> /dev/null)
    if [[ -n "$_INDEX" ]]; then
      # if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      #   # Staged
      #   _STATUS="$_STATUS📦"
      # fi
      # if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      #   # Unstaged
      #   _STATUS="$_STATUS🤖"
      # fi
      # if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      #   # Untracked
      #   _STATUS="$_STATUS✨"
      # fi
      if $(echo "$_INDEX" | command grep -q '^UU '); then
        # Unmerged
        _STATUS="$_STATUS⛔️"
      fi
    # else
    #   # Clean
    #   _STATUS="$_STATUS✅"
    fi

    # check status of local repository
    _INDEX=$(command git status --porcelain -b 2> /dev/null)
    if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
      # Ahead
      _STATUS="$_STATUS🚀"
    fi
    if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
      # Behind
      _STATUS="$_STATUS🐌"
    fi
    if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
      # Diverged
      _STATUS="$_STATUS😱"
    fi

    if $(command git rev-parse --verify refs/stash &> /dev/null); then
      # Stashed
      _STATUS="$_STATUS💾"
    fi

    echo $_STATUS

  }

  function iterm2_print_user_vars {
    local ref dirty customLabel customGit profile

    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
      ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="‼️$(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
      # customLabel="${customLabel} : ${ref/refs\/heads\//} $(buildGitStatusLabel)"
      customLabel="${ref/refs\/heads\//}$(buildGitStatusLabel)"
    else
      customLabel=$(pwd | sed -e "s,^$HOME,~," | sed "s@\(.\)[^/]*/@\1/@g")
    fi

    if [ ${DDT_PROFILE} ]; then
      customLabel="${customLabel}:${DDT_PROFILE}"
    fi

    "${HOME}/.iterm2/it2setkeylabel" set status "$customLabel"
  }

  function setBadge {
    local badge="${@}"
    iterm2_set_user_var session "${badge}"
  }

