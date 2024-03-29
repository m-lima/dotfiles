#!/usr/bin/env bash
# 

bg='colour235'
if command -v simpalt &> /dev/null
then
  simpalt t "${1}"
else
  branch=`git -C "${1}" symbolic-ref --short HEAD || git -C "${1}" rev-parse --short HEAD`
  if [ "${branch}" ]
  then
    echo -n "#[fg=colour237]#[fg=magenta,bg=colour237] #[fg=colour246]${branch} "
    bg='colour237'
  fi
fi

playing=`$(dirname "${0}")/spotify.script`
if [ "${playing}" ]
then
  echo -n "#[fg=colour234]#[fg=colour37,bg=colour234] ${playing} "
  bg='colour234'
fi

echo -n "#[fg=colour239]#[fg=colour248,bg=colour239] $(date | cut -d':' -f1-2) "
