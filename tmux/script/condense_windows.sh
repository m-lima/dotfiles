#!/usr/bin/env bash

windows=$(tmux list-windows -F '#I:#W')
scratch=$(grep '^[0-9]*:scratch$' <<<"${windows}" | cut -d ':' -f 1)

if [ -n "${scratch}" ]; then
  curr=$(tmux display-message -p '#I')
  last=$(( $(tail -1 <<<"${windows}" | cut -d ':' -f 1) + 1 ))
  if (( scratch != curr)); then
    background='-d'
  fi
  tmux move-window -t "${last}" -s "${scratch}" $background
fi

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
