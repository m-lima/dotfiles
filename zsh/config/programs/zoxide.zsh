source <(zoxide init zsh)

function zz {
  if [ "$#" -eq 0 ]; then
    cd ~
    return
  fi

  local entries=$(zoxide query --list --exclude "${PWD}" "$2")

  if [  -z "$entries" ]; then
    echo "No matches" >&2
    return 1
  fi

  if [[ "$entries" =~ $'\n' ]]; then
    local result=$(fzf <<<"$entries") && cd "$result"
  else
    cd "$entries"
  fi
}

function _zz {
  if (( CURRENT == 2 )); then
    local entries=$(zoxide query --list --exclude "${PWD}" "${words[2]}")

    if [  -z "$entries" ]; then
      return
    fi

    if [[ "$entries" =~ $'\n' ]]; then
      local result=$(fzf <<<"$entries")
      if [ -n "$result" ]; then
        compadd -U -r -- "$result"
      fi
    else
      compadd -U -r -- "$entries"
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
