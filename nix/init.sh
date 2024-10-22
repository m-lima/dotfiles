#!/usr/bin/env bash

base=$(dirname $(realpath "${0}"))

if [ -z "${1}" ]; then
  echo "Host name not provided" >&2
  echo "Available hosts:" >&2
  ls ${base}/hosts | xargs -I{} echo {}
  exit 1
fi

host=${1}

set -e

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko "${base}/hosts/${host}/disko.nix"

mkdir /persist/secrets
echo Setting password for root
mkpasswd > /persist/secrets/root.passwordFile
echo Setting password for celo
mkpasswd > /persist/secrets/celo.passwordFile

nixos-install --flake "${base}#${host}"
