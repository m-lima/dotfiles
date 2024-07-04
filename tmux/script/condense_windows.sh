#!/usr/bin/env bash

windows=( $(tmux list-windows -F '#I') )
curr=$(tmux display-message -p '#I')
expected=1

for id in ${windows[@]}; do
  if [ "${expected}" -ne "${id}" ]; then
    if (( curr != id )); then
      background='-d'
    else
      unset background
    fi
    tmux move-window -t "${expected}" -s "${id}" $background
  fi

  expected=$(( expected + 1 ))
done
