#!/usr/bin/env bash

set -e

base=$(dirname $(realpath "${0}"))

if [ -z "${1}" ]; then
  echo "[31mHost name not provided. Available hosts:[m" >&2
  ls ${base}/hosts | xargs -I{} echo {}
  exit 1
fi

host=${1}

if ! [ -d "${base}/hosts/${host}" ]; then
  echo "[31mHost not yet configured. Available hosts:[m" >&2
  ls ${base}/hosts | xargs -I{} echo {}
  exit 1
fi

if [ -z "${3}" ]; then
  user='celo'
else
  user="${3}"
fi

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

function mkHardwareConfig {
  if [ -f "${base}/hosts/${host}/hardware-configuration.nix" ]; then
    echo -n "[33mWARNING!![m There already exists a hardware configuration at ${base}/hosts/${host}/hardware-configuration.nix. Proceed? [y/N] "
    read input
    case "${input}" in
      [Yy] ) ;;
      * ) exit ;;
    esac
  fi
  nixos-generate-config --no-filesystems --root /mnt
  cp /mnt/etc/nixos/hardware-configuration.nix "${base}/hosts/${host}/."
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

  mkdir -p /mnt/persist/secrets
  mkdir -p /mnt/persist/secrets/root
  echo "[34mSetting password for root[m"
  get_password | mkpasswd -s > /mnt/persist/secrets/root/passwordFile
  mkdir -p "/mnt/persist/secrets/${user}"
  echo "[34mSetting password for ${user}[m"
  get_password | mkpasswd -s > "/mnt/persist/secrets/${user}/passwordFile"
}

function mksshid {
  mkdir -p "/mnt/persist/secrets/${user}"
  ssh-keygen -t ed25519 -C "${user}@${host}" -N '' -f "/mnt/persist/secrets/${user}/id_ed25519"
}

function rekey {
  function copyPrivKey {
    mkdir -p "${base}/secrets/pubkey/${host}"
    cp /etc/ssh/ssh_host_ed25519_key.pub "${base}/secrets/pubkey/${host}/ssh.key.pub"
    cp "/mnt/persist/secrets/${user}/id_ed25519.pub" "${base}/modules/services/ssh/secrets/${user}-${host}.pub"
  }

  function copySshKey {
    cp /etc/ssh/ssh_host_rsa_key* /mnt/persist/etc/ssh/.
  }

  function rekeyEdit {
    cd "${base}"
    nix run github:oddlama/agenix-rekey -- edit -i "/mnt/persist/secrets/${user}/id_ed25519" "./modules/services/ssh/secrets/${user}-${host}.age"
  }

  if [ -f "${base}/secrets/pubkey/${host}/ssh.key.pub" ]; then
    echo -n "[33mWARNING!![m There already exists a public key at ${base}/secrets/pubkey/${host}/ssh.key.pub. Proceed? [y/N] "
    read input
    case "${input}" in
      [Yy] ) copyPrivKey ;;
      * ) ;;
    esac
  else
    copyPrivKey
  fi

  if [ -f "${base}/modules/services/ssh/secrets/${user}-${host}.age" ]; then
    echo -n "[33mWARNING!![m There already exists a private key at ${base}/modules/services/ssh/secrets/${user}-${host}.age. Proceed? [y/N] "
    read input
    case "${input}" in
      [Yy] )
        rm "${base}/modules/services/ssh/secrets/${user}-${host}.age"
        rekeyEdit
        ;;
      * ) ;;
    esac
  else
    rekeyEdit
  fi

  cd "${base}"
  git add .
  nix run github:oddlama/agenix-rekey -- rekey
  git add .

  if [ -f /mnt/persist/etc/ssh/ssh_host_ed25519_key ]; then
    echo -n "[33mWARNING!![m There already exists a key at /mnt/persist/etc/ssh/ssh_host_ed25519_key. Overwrite? [y/N] "
    read input
    case "${input}" in
      [Yy] ) cp /etc/ssh/ssh_host_ed25519_key* /mnt/persist/etc/ssh/. ;;
      * ) return ;;
    esac
  else
    cp /etc/ssh/ssh_host_ed25519_key* /mnt/persist/etc/ssh/.
  fi

  if [ -f /mnt/persist/etc/ssh/ssh_host_rsa_key ]; then
    echo -n "[33mWARNING!![m There already exists a key at /mnt/persist/etc/ssh/ssh_host_rsa_key. Overwrite? [y/N] "
    read input
    case "${input}" in
      [Yy] ) copySshKey ;;
      * ) return ;;
    esac
  else
    copySshKey
  fi
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
  "prepare")
    format && mkHardwareConfig && mkpass && mksshid && rekey && prepare_persist
    ;;
  "all")
    format && mkHardwareConfig && mkpass && mksshid && rekey && prepare_persist && vi "${base}/hosts/${host}/default.nix" && install
    ;;
  * )
    shift
    ${@}
    ;;
esac
