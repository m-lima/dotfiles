#!/usr/bin/env bash

# TODO: Make this nix

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

  echo "[34mnix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode disko '${base}/hosts/${host}/disko.nix'[m"
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko "${base}/hosts/${host}/disko.nix"
}

function mkpass {
  mkdir /mnt/persist/secrets
  echo "[34mSetting password for root[m"
  mkpasswd > /mnt/persist/secrets/root.passwordFile
  echo "[34mSetting password for celo[m"
  mkpasswd > /mnt/persist/secrets/celo.passwordFile
}

function prepare_persist {
  echo "[34mCreating dotfiles in persist[m"
  cp -a ${base}/.. /mnt/persist/dotfiles
  mkdir /mnt/persist/etc
  ln -s /persist/dotfiles/nix /mnt/persist/etc/nixos
}

function install {
  nixos-install --flake "${base}#${host}"
}

case "${2}" in
  "all")
    format && mkpass && prepare_persist && install
    ;;
  "mount")
    mount
    ;;
  "mkpass")
    mkpass
    ;;
  "install")
    install
    ;;
esac
