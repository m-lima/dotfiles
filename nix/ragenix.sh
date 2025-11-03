#!/usr/bin/env zsh

function usage {
  binary="$(basename "${0}")"
  cat <<EOF
Usage: ${binary} <ACTION> [IDENTITY]

ACTION:
  e|encrypt <INPUT> <OUTPUT>
    Encrypt INPUT into OUTPUT using IDENTITY, where OUPUT is a path, INPUT is a
    literal value

  d|decrypt <INPUT>
    Decrypt INPUT into OUTPUT using IDENTITY, where all parameters are paths

IDENTITY:
  Defaults to /etc/ssh/ssh_host_ed25519_key for decryption,
  and /etc/ssh/ssh_host_ed25519_key.pub for decryption
EOF
}

function encrypt {
  local input="${1}"
  local output="${2}"
  local identity="/etc/ssh/ssh_host_ed25519_key.pub"

  if [ -z "${input}" ]; then
    echo "Missing INPUT" >&2
    echo "" >&2
    usage >&2
    exit 1
  fi

  if [ -z "${output}" ]; then
    echo "Missing OUPUT" >&2
    echo "" >&2
    usage >&2
    exit 1
  fi

  if [[ "${3}" == "all" ]]; then
    identity=()
    for r in "$(realpath $(dirname "${0}"))"/secrets/pubkey/*/*.pub; do
      identity+="-R"
      identity+="${r}"
    done
    echo "'${identity}'"
  else
    if [ -n "${3}" ]; then
      identity="${3}"
    fi

    if ! [ -f "${identity}" ]; then
      echo "File ${identity} does not exist" >&2
      exit 1
    fi

    identity=("-R" "${identity}")
  fi

  rage -e ${identity[@]} -o "${output}" <<<"${input}"
}

function decrypt {
  local input="${1}"
  local identity="/etc/ssh/ssh_host_ed25519_key"
  local sudo="";

  if [ -z "${input}" ]; then
    echo "Missing INPUT" >&2
    echo "" >&2
    usage >&2
    exit 1
  fi

  if ! [ -f "${input}" ]; then
    echo "File ${input} does not exist" >&2
    exit 1
  fi

  if ! [ -r "${input}" ]; then
    echo "Cannot read ${input}" >&2
    exit 1
  fi

  if [ "${2}" ]; then
    identity="${2}"
  fi

  if ! [ -f "${identity}" ]; then
    echo "File ${identity} does not exist" >&2
    exit 1
  fi

  if ! [ -r "${identity}" ]; then
    sudo="sudo";
  fi

  ${sudo} rage -d -i "${identity}" "${input}"
}

case "${1}" in
  "e"|"encrypt") encrypt "${2}" "${3}" "${4}";;
  "d"|"decrypt") decrypt "${2}" "${3}" "${4}";;
  *)
    echo "Unknown command" >&2
    echo "" >&2
    usage >&2
    exit 1
    ;;
esac
