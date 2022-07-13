#!/usr/bin/env bash

if [[ "${1}" == all ]]
then
  for scratch in `tmux list-sessions -F "#{session_name}" | grep '^scratch-'`
  do
    tmux kill-session -t "${scratch}"
  done
else
  all_windows=`tmux list-windows -a -F "#{session_id}#{window_id}:#{session_name}" | grep -v ':scratch-'`
  for scratch in `tmux list-sessions -F "#{session_name}" | grep '^scratch-'`
  do
    grep "${scratch#scratch-}" <<<${all_windows} > /dev/null || tmux kill-session -t "${scratch}"
  done
fi

