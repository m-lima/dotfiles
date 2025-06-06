#!/usr/bin/env bash

########################################
# Clean deprecated files

function checkPath {
  if [ -f "${1}" ] || [ -d "${1}" ] || [ -L "${1}" ]
  then
      echo -n "${1} is deprecated but still exists. Delete? [y/N] "
      read input
      case ${input} in
        [Yy] ) rm -rf "${1}" ;;
      esac
  fi
}

checkPath "${HOME}/.tmux.conf"
checkPath "${HOME}/.tmux.conf.local"
checkPath "${HOME}/.tmux-powerlinerc"
checkPath "${HOME}/.config/m-lima/delta"
checkPath "${HOME}/.config/m-lima/alacritty"

########################################
# Clean deprecated zsh vars

function checkVar {
  if grep -w "${1}" "${HOME}/.config/m-lima/zsh/local.zsh" &> /dev/null
  then
    echo "${1} is no longer in use. Use "${2}" instead in ~/.config/m-lima/zsh/local.zsh"
  fi
}

checkVar localPlugins local_plugins
checkVar pluginManager local_pluginManager
checkVar zshFramework local_zshFramework

########################################
# Move files

if [ -d "${HOME}/.config/m-lima/fd" ]; then
  echo "${HOME}/.config/m-lima/fd is no longer in use. Use "${HOME}/.config/m-lima/fd" instead"
  if [ ! -d "${HOME}/.config/m-lima/td" ]; then
    echo "Move? [y/N] "
    read input
    case ${input} in
      [Yy] ) mv "${HOME}/.config/m-lima/fd" "${HOME}/.config/m-lima/td" ;;
    esac
  fi
fi
