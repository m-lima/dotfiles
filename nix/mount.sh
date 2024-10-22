#!/usr/bin/env bash

# TODO: Make this nix

base=$(dirname $(realpath "${0}"))

if [ -z "${1}" ]; then
  echo "[31mHost name not provided. Available hosts:[m" >&2
  ls ${base}/hosts | xargs -I{} echo {}
  exit 1
fi

host=${1}

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode mount "${base}/hosts/${host}/disko.nix"
