#!/usr/bin/env bash

base=$(dirname $(realpath "${0}"))

if [ -z "${1}" ]; then
  echo "[31mHost name not provided. Available hosts:[m" >&2
  ls ${base}/hosts | xargs -I{} echo {}
  exit 1
fi

host=${1}

function format {
  echo -n "[33mWARNING!![m This will format the disk. Proceed? [y/N] "
  read input
  case "${input}" in
    [Yy] ) ;;
    * ) exit ;;
  esac

  echo "[34mnix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode disko --flake '${base}#${host}'[m"
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko --flake "${base}#${host}"
}

function mount {
  echo "[34mnix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode mount --flake '${base}#${host}'[m"
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode mount --flake "${base}#${host}"
}

function mkpass {
  function get_password {
    local password confirmation

    while true; do
      printf 'Password: ' >&2
      read -s password
      echo >&2
      printf 'Password (again): ' >&2
      read -s confirmation
      echo >&2
      [ "${password}" = "${confirmation}" ] && printf "${password}" && break
      echo "Please try again" >&2
    done
  }

  local user
  if [ -z "${1}" ]; then
    user='celo'
  else
    user="${1}"
  fi

  mkdir /mnt/persist/secrets
  mkdir /mnt/persist/secrets/root
  echo "[34mSetting password for root[m"
  get_password | mkpasswd -s > /mnt/persist/secrets/root/passwordFile
  mkdir "/mnt/persist/secrets/${user}"
  echo "[34mSetting password for ${user}[m"
  get_password | mkpasswd -s > "/mnt/persist/secrets/${user}/passwordFile"
}

function mksshid {
  local user
  if [ -z "${1}" ]; then
    user='celo'
  else
    user="${1}"
  fi

  mkdir -p "/mnt/persist/secrets/${user}"
  ssh-keygen -t ed25519 -C "${user}@${host}" -N '' -f "/mnt/persist/secrets/${user}/id_ed25519"
}

function prepare_persist {
  echo "[34mCreating dotfiles in persist[m"
  cp -a ${base}/.. /mnt/persist/dotfiles
  mkdir -p /mnt/persist/etc/nixos
  ln -s /persist/dotfiles/nix/flake.nix /mnt/persist/etc/nixos/.
}

function install {
  echo "[34mnixos-install --flake '${base}#${host}'[m"
  nixos-install --flake "${base}#${host}"
}

case "${2}" in
  "all")
    format && mkpass "${3}" && mksshid "${3}" && prepare_persist && install
    ;;
  "mount")
    mount
    ;;
  "mkpass")
    mkpass "${3}"
    ;;
  "mksshid")
    mksshid "${3}"
    ;;
  "install")
    install
    ;;
  * )
    echo "[31mUnrecognized command '${2}'. Available commands:[m" >&2
    echo all
    echo mount
    echo mkpass
    echo mksshid
    echo install
    exit 1
    ;;
esac
