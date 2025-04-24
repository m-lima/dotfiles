function zz {
  if [ "$#" -eq 0 ]; then
    cd ~
    return
  fi

  local entries=$(zoxide query --list --exclude "${PWD}" "$@")

  if [ -z "$entries" ]; then
    echo "No matches" >&2
    return 1
  fi

  local result=$(fzf -1 <<<"$entries") && cd "$result"
}

function _zz_var {
  echo -n "$1 = '" >> /tmp/zz.out
  eval echo -n $"$1" >> /tmp/zz.out
  echo "'" >> /tmp/zz.out
}

if [ -z $_ZZ_BINDING ]; then
  export _ZZ_BINDING='^I'
  _zz_var _ZZ_BINDING
fi

if [ -z $_ZZ_FALLBACK ]; then
  export _ZZ_FALLBACK=$(PREFIX="'$_ZZ_BINDING'  "; bindkey "$_ZZ_BINDING" | tail -c +$#PREFIX)
  _zz_var _ZZ_FALLBACK
fi

unset _ZZ_BINDING

# if ! declare -p _ZZ_COMMANDS &> /dev/null; then
#   export _ZZ_COMMANDS=( cd )
#   echo "_ZZ_COMMANDS=$_ZZ_COMMANDS" >> /tmp/zz.out
# fi
#
# if [ -z $_ZZ_COMMAND_REGEX ] && (( $#_ZZ_COMMANDS > 0 )); then
#   export _ZZ_COMMAND_REGEX="[[:space:]]*(${_ZZ_COMMANDS[1]}"
#
#   if (( $#_ZZ_COMMANDS > 1 )); then
#     for i in {2..$#_ZZ_COMMANDS}; do
#       _ZZ_COMMAND_REGEX="$_ZZ_COMMAND_REGEX|${_ZZ_COMMANDS[$i]}"
#     done
#   fi
#   _ZZ_COMMAND_REGEX="$_ZZ_COMMAND_REGEX)[[:space:]]+"
#   echo "_ZZ_COMMAND_REGEX=$_ZZ_COMMAND_REGEX" >> /tmp/zz.out
# fi

export _ZZ_PATH_ROOT
zle -C _zz_complete_path expand-or-complete _zz_complete_path_wrapper

function _zz_complete_path_wrapper {
  _zz_var _ZZ_PATH_ROOT
  _path_files -W "$_ZZ_PATH_ROOT" -/
}

function _zz {
  local words=(${(z)BUFFER})

  if [[ "${words[1]}" != "zz" ]] && [[ "${words[1]}" != "\zz" ]] && [[ "${words[1]}" != "'zz'" ]] && [[ "${words[1]}" != '"zz"' ]]; then
    zle $_ZZ_FALLBACK
    return
  fi

  local w offset new_pos=0 pos=0 remaining="$BUFFER"
  local current=0 current_word

  for w in "${words[@]}"; do
    offset="${remaining%%$w*}"
    new_pos=$(( $#BUFFER - $#remaining + $#offset ))
    (( new_pos > CURSOR )) && break
    pos="$new_pos"
    current=$(( current + 1 ))
    current_word="$w"
    remaining="${remaining#*$w}"
  done

  local current_word_end=$(( pos + $#current_word + 1 ))

  if (( CURSOR >= current_word_end )); then
    pos="$CURSOR"
    current=$(( current + 1 ))
    current_word=""
    current_word_end=$(( pos + 1 ))
  fi

  # tr "\t" '·' <<<$BUFFER >> /tmp/zz.out
  # if [ $CURSOR -ne '0' ]; then
  #   for i in {1..$CURSOR}; do
  #     echo -n " " >> /tmp/zz.out
  #   done
  # fi
  # echo "^$current :: ${current_word} ($CURSOR)" >> /tmp/zz.out
  # echo "$BUFFER" >> /tmp/zz.out
  # echo "${BUFFER[1,$pos]}__${BUFFER[$current_word_end,-1]}" >> /tmp/zz.out

  if (( current == 2 )); then
    local raw_list=$(zoxide query --list --exclude "$PWD" "$current_word")
    local lines=(${(@f)raw_list})
    lines="${#lines[@]}"

    if [ "$lines" -eq '0' ]; then
      zle -M "No results"
      return
    elif [ "$lines" -eq '1' ]; then
      # raw_list="${raw_list/#$HOME/~}"
      BUFFER="${BUFFER[1,$pos]}${raw_list}${BUFFER[$current_word_end,-1]}"
      CURSOR=$(( pos + $#raw_list + 1))
    else
      local result=$(fzf <<<$raw_list)
      # result="${result/#$HOME/~}"
      BUFFER="${BUFFER[1,$pos]}${result}${BUFFER[$current_word_end,-1]}"
      CURSOR=$(( pos + $#result + 1 ))
    fi
  elif (( current == 3 )); then
    if [ -d "${words[2]}" ]; then
      _ZZ_PATH_ROOT="${words[2]}"
      zle _zz_complete_path
    else
      zle -M "Not resolved for '${words[2]}'"
      return
    fi
  else
    zle $_ZZ_FALLBACK
  fi

  # local current=-1
  # # echo "== $(date) _zz" >> /tmp/zz.out
  # # if ! [[ "$BUFFER" =~ $_ZZ_COMMAND_REGEX ]]; then
  # #   echo "Buffer does not start with 'cd'" >> /tmp/zz.out
  # #   zle $_ZZ_FALLBACK
  # #   return
  # # fi
  #
  # local lwords=(${(z)LBUFFER})
  #
  # if [[ "${lwords[1]}" != "zz" ]]; then
  #   echo "Buffer does not start with 'zz'" >> /tmp/zz.out
  #   zle $_ZZ_FALLBACK
  #   return
  # fi
  #
  # if [[ "${LBUFFER[-1]}" == [[:space:]] ]]; then
  #   local len=$(( $#lwords + 1 ))
  # else
  #   local len=$#lwords
  # fi
  #
  # _zz_var LBUFFER
  # _zz_var RBUFFER
  #
  # local words=(${(z)BUFFER})
  # echo -n "words = " >> /tmp/zz.out
  # for i in ${words[@]}; do
  #   echo -n "'$i' " >> /tmp/zz.out
  # done
  # echo >> /tmp/zz.out
  # echo -n "lwords = " >> /tmp/zz.out
  # for i in ${lwords[@]}; do
  #   echo -n "'$i' " >> /tmp/zz.out
  # done
  # echo >> /tmp/zz.out
  #
  # tr "\t" '·' <<<$BUFFER >> /tmp/zz.out
  # for i in {1..$CURSOR}; do
  #   echo -n " " >> /tmp/zz.out
  # done
  # echo "^$len - ${words[$len]}" >> /tmp/zz.out
  #
  # local lquery="${LBUFFER##*[[:space:]]}"
  # local rquery="${RBUFFER%%[[:space:]]*}"
  # local query="$lquery$rquery"
  # local clean="${LBUFFER%%$lquery}${RBUFFER##$rquery}"
  # echo "'$lquery|$rquery'" >> /tmp/zz.out
  # _zz_var query
  # _zz_var clean
  #
  # local marker=$'\001'$'\001'$'\001'
  # local buffer="${LBUFFER}${marker}${RBUFFER}"
  # _zz_var buffer
  #
  # local bwords=(${(z)buffer})
  # _zz_var bwords
  #
  # local current=-1
  #
  # for i in {1..$#bwords}; do
  #   if [[ "${bwords[$i]}" == *${marker}* ]]; then
  #     current=$i
  #     break
  #   fi
  # done
  #
  # _zz_var current
  # if [ $i -eq '-1' ]; then
  #   return
  # fi
  #
  # local curr_word="${bwords[$i]}"
  # _zz_var curr_word
  #
  # # if [ $len -eq 2 ]; then
  # #   local lquery="${LBUFFER##*[[:space:]]}"
  # #   local rquery="${RBUFFER%%[[:space:]]*}"
  # # local query="$lquery$rquery"
  # #   local clean="${LBUFFER%%$lquery}${RBUFFER##$rquery}"
  # #   local result=$(fzf -1 <<<$(zoxide query --list --exclude "${PWD}" "$query"))
  # #   if [ -n $result ]; then
  # #     local left="${LBUFFER%[[:space:]]*}"
  # #     echo "result='$result'" >> /tmp/zz.out
  # #     echo "left='$left'" >> /tmp/zz.out
  # #     LBUFFER="$left $result "
  # #   fi
  # # elif [ $len -eq 3 ]; then
  # #   _path_files -W "${words[2]}" -/
  # # else
  # #   zle $_ZZ_FALLBACK
  # # fi
}

zle -N _zz
bindkey '^I' _zz

# function _zz_comp {
#   _zz_var CURRENT
#   _zz_var CURSOR
#   echo -n "words = " >> /tmp/zz.out
#   for i in ${words[@]}; do
#     echo -n "'$i' " >> /tmp/zz.out
#   done
#   echo >> /tmp/zz.out
#   echo '---' >> /tmp/zz.out
#   declare -p | sort >> /tmp/zz.out
#   echo '---' >> /tmp/zz.out
#
#   if (( CURRENT == 2 )); then
#     result="blablabla"
#     compadd $result
#     return
#
#     local entries=$(zoxide query --list --exclude "${PWD}" "${words[2]}")
#
#     if [ -z "$entries" ]; then
#       return
#     fi
#
#     local result=$(fzf -1 <<<"$entries") && _values "Directory" "$result"
#   elif (( CURRENT == 3 )); then
#     _path_files -W "${words[2]}" -/
#   fi
# }
#
# compdef _zz_comp zz
# # # zstyle ':completion:*:*:zz:*:*' completer _expand
# # zstyle ':completion:*:zz:*' completer _expand
