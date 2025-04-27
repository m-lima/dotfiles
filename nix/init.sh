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
  echo "[34mFormatting disks[m"

  echo -n "[33mWARNING!![m This will format the disk. Proceed? [y/N/a] "
  read input
  case "${input}" in
    [Yy]) ;;
    [Aa]) exit ;;
    *) return ;;
  esac

  echo "[34mnix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode disko --flake '${base}#${host}'[m"
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko --flake "${base}#${host}"
}

function mount {
  echo "[34mMounting disks[m"

  echo "[34mnix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode mount --flake '${base}#${host}'[m"
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode mount --flake "${base}#${host}"
}

function mkHardwareConfig {
  echo "[34mMaking hardware config[m"

  if [ -f "${base}/hosts/${host}/hardware-configuration.nix" ]; then
    echo -n "[33mWARNING!![m There already exists a hardware configuration at ${base}/hosts/${host}/hardware-configuration.nix. Proceed? [y/N/a] "
    read input
    case "${input}" in
      [Yy]) ;;
      [Aa]) exit ;;
      *) return ;;
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

  function mkUserPass {
    echo "[34mSetting password for ${1}[m"

    if [ -f "${2}" ]; then
      echo -n "[33mWARNING!![m There already exists a password for '${1}'. Proceed? [y/N/a] "
      read input
      case "${input}" in
        [Yy]) rm "${2}" ;;
        [Aa]) exit ;;
        *) return ;;
      esac
    fi

    temp="$(mktemp)" && \
    get_password | mkpasswd -s >"${temp}" && \
    nix run github:oddlama/agenix-rekey -- edit -i "${temp}" "${2}"
    rm "${temp}"
  }

  mkUserPass root "${base}/modules/core/nixos/secrets/${host}.age"
  mkUserPass "${user}" "${base}/modules/core/user/secrets/${host}.age"
}

function mksshid {
  echo "[34mMaking SSH id[m"

  if [ -f "${base}/modules/services/ssh/secrets/${user}-${host}.age" ]; then
    echo -n "[33mWARNING!![m There already exists an SSH key at '${base}/modules/services/ssh/secrets/${user}-${host}.age'. Proceed? [y/N/a] "
    read input
    case "${input}" in
      [Yy])
        rm "${base}/modules/services/ssh/secrets/${user}-${host}.age"
        rm "${base}/modules/services/ssh/secrets/${user}-${host}.pub"
        ;;
      [Aa]) exit ;;
      *) return ;;
    esac
  fi

  temp="$(mktemp)" && \
  rm "${temp}" && \
  ssh-keygen -t ed25519 -C "${user}@${host}" -N '' -f "${temp}" && \
  mv "${temp}.pub" "${base}/modules/services/ssh/secrets/${user}-${host}.pub" && \
  cd "${base}" && \
  nix run github:oddlama/agenix-rekey -- edit -i "${temp}" "./modules/services/ssh/secrets/${user}-${host}.age" && \
  rm "${temp}"

  git add "./modules/services/ssh/secrets/${user}-${host}.age"
  git add "./modules/services/ssh/secrets/${user}-${host}.pub"
}

function rekey {
  function copyPubKey {
    echo "[34mCopying host public SSH key[m"

    if [ -f "${base}/secrets/pubkey/${host}/ssh.key.pub" ]; then
      echo -n "[33mWARNING!![m There already exists a public key at ${base}/secrets/pubkey/${host}/ssh.key.pub. Proceed? [y/N/a] "
      read input
      case "${input}" in
        [Yy]) ;;
        [Aa]) exit ;;
        *) return ;;
      esac
    fi

    if ! [ -f /etc/ssh/ssh_host_ed25519_key.pub ]; then
      echo -n "[31mERROR!![m There is no key at /etc/ssh/ssh_host_ed25519_key.pub. Continuing.."
    fi

    mkdir -p "${base}/secrets/pubkey/${host}"
    cp /etc/ssh/ssh_host_ed25519_key.pub "${base}/secrets/pubkey/${host}/ssh.key.pub"
  }

  function copySshKey {
    echo "[34mCopy outer SSH key into mounted disks[m"

    if ! [ -d "/mnt/persist" ]; then
      echo -n "[33mWARNING!![m There doesn't seem to be a persistent mount in /mnt/persist. Continuing.."
      return
    fi

    if [ -f "/mnt/persist/etc/ssh/${1}" ]; then
      echo -n "[33mWARNING!![m There already exists a key at /mnt/persist/etc/ssh/${1}. Overwrite? [y/N/a] "
      read input
      case "${input}" in
        [Yy]) ;;
        [Aa]) exit ;;
        *) return ;;
      esac
    fi

    if ! [ -f "/etc/ssh/${1}" ]; then
      echo -n "[31mERROR!![m There is no key at /etc/ssh/${1}.  Continuing.."
      return
    fi

    mkdir -p /mnt/persist/etc/ssh/
    cp /etc/ssh/"${1}"* /mnt/persist/etc/ssh/.
  }

  copyPubKey

  cd "${base}"
  git add .
  nix run github:oddlama/agenix-rekey -- rekey -a

  copySshKey ssh_host_ed25519_key
  copySshKey ssh_host_rsa_key
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

  echo -n "[33mWARNING!![m If this is the first install after a rekey, make sure all secrets are in place, and re-install or enter into the mount"
}

case "${2}" in
  "prepare")
    format && mkHardwareConfig && mkpass && mksshid && rekey && prepare_persist
    ;;
  "all")
    format && mkHardwareConfig && mkpass && mksshid && rekey && prepare_persist && vi "${base}/hosts/${host}/default.nix" && install
    ;;
  *)
    shift
    ${@}
    ;;
esac
