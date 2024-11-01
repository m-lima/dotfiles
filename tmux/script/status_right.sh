#!/usr/bin/env bash
# 

base=$(dirname $(realpath "${0}"))

if command -v simpalt &> /dev/null
then
  source "${base}/status/simpalt.sh"
else
  source "${base}/status/git.sh"
fi

source "${base}/status/spotify.sh" "${base}"

source "${base}/status/time.sh"
