source <(zoxide init zsh)

function zz {
  if [ "${#}" -eq 0 ]; then
    cd ~
    return
  fi

  local entries
  if [ -z "${2}" ]; then
    entries=$(zoxide query --list --exclude "${PWD}" "${1}")
  else
    entries=$(zoxide query --list "${1}")
  fi

  if [  -z "${entries}" ]; then
    echo "No matches" >&2
    return 1
  fi

  if [[ "${entries}" =~ $'\n' ]]; then
    local result=$(CLICOLOR=1 CLICOLOR_FORCE=1 SHELL=sh fzf '--preview=\command -p ls -ACp --color=always --group-directories-first {}' '--preview-window=down,30%,sharp' <<<"${entries}")
    if [ -n "${result}" ]; then
      cd "${result}/${2}"
    fi
  else
    [ -d "${entries}/${2}" ] && echo "${entries}/${2}"
    cd "${entries}/${2}"
  fi
}

function _zz {
  # zstyle ':completion:*:*:*:default' menu yes select search

  if (( CURRENT == 2 )); then
    local entries=$(zoxide query --list --exclude "${PWD}" "${words[2]}")

    if [ -z "${entries}" ]; then
      return
    fi

    if [[ "${entries}" =~ $'\n' ]]; then
      local result=$(CLICOLOR=1 CLICOLOR_FORCE=1 SHELL=sh fzf '--preview=\command -p ls -ACp --color=always --group-directories-first {}' '--preview-window=down,30%,sharp' <<<"${entries}")
      if [ -n "${result}" ]; then
        compadd -U -Q -- "${result}"
      fi
    else
      compadd -U -Q -- "${entries}"
    fi
  elif (( CURRENT == 3 )); then
    if [ -d "${words[2]}" ]; then
      _path_files -W "${words[2]}" -/
    else
      zle -M "Not resolved for '${words[2]}'"
    fi
  fi
}

compdef _zz zz
