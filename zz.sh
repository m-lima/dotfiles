#!/usr/bin/env bash

function zz {
  if [ "$#" -eq 0 ]; then
    cd ~
    return
  fi

  local entries=$(zoxide query --list --exclude "${PWD}" "$@")
  # local prev e result

  if [ -z "$entries" ]; then
    echo "No matches" >&2
    return 1
  fi

  local result=$(fzf -1 <<<"$entries") && cd "$result"

  # if [[ $entries =~ $'\n' ]]; then
  #   local result=$(fzf <<<"$entries") && cd "$result"
  # else
  #   cd "$entries"
  # fi


  # while read e; do
  #   if [ -n "$prev" ]; then
  #     result=$(fzf <<<"$entries") && cd "$result"
  #     return
  #   else
  #     prev="$e"
  #   fi
  # done <<<"$entries"
  #
  # echo "$entries"
  # cd "$entries"
}

# function _zz {
#   if (( CURRENT == 2 )); then
#     local entries=$(zoxide query --list --exclude "${PWD}" "$words[2]")
#     zle kill_buffer
#     # local result=$(fzf -1 <<<"$entries") && LBUFFER="cd" && RBUFFER="$result" && zle reset-prompt
#     # local prev e result
#     #
#     # [ -z "$entries" ] && return
#     #
#     # while read e; do
#     #   if [ -n "$prev" ]; then
#     #     result=$(fzf <<<"$entries") && echo "$result"
#     #     return
#     #   else
#     #     prev="$e"
#     #   fi
#     # done <<<"$entries"
#     #
#     # echo "$entries"
#   elif (( CURRENT == 3 )); then
#     local entries=$(zoxide query --list --exclude "${PWD}" "$words[2]")
#     local prev e result
#
#     [ -z "$entries" ] && return
#
#     while read e; do
#       if [ -n "$prev" ]; then
#         result=$(fzf <<<"$entries") && _path_files -W "$result" -/
#         return
#       else
#         prev="$e"
#       fi
#     done <<<"$entries"
#
#     _path_files -W "$entries" -/
#   fi
# }

function _zz {
  local words=(${(z)LBUFFER})

  if [[ "${words[1]}" != "zz" ]]; then
    fzf-completion
    return
  fi

  if [[ "${BUFFER[-1]}" == [[:space:]] ]]; then
    local len=$(( $#words + 1 ))
  else
    local len=$#words
  fi

  if (( len == 2 )); then
    local result=$(fzf -1 <<<$(zoxide query --list --exclude "${PWD}" "${words[2]}"))
    local left="${LBUFFER%[[:space:]]*}"
    printf "${RBUFFER}"
    LBUFFER="$left $result "
  elif (( len == 3 )); then
    # _path_files -W "${words[2]}" -/
  else
    fzf-completion
  fi
}

zle -N _zz
# bindkey '^I' _zz
# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:zz:*' _zz

# compdef _zz zz
