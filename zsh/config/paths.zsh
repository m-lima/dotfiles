# Adding local bin to path
export PATH="${HOME}/bin${PATH+:$PATH}"

# Brew on M1
if [ -s "/opt/homebrew/bin/brew" ]
then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export LIBRARY_PATH="${HOMEBREW_PREFIX}/lib${LIBRARY_PATH+:$LIBRARY_PATH}"
  export CPATH="${HOMEBREW_PREFIX}/include${CPATH+:$CPATH}"
fi

# Go
if [ -d "${HOME}/code" ] && command -v go &> /dev/null
then
  export GOPATH="${HOME}/code/go/root"
  export PATH="${GOPATH}/bin${PATH+:$PATH}"
fi

# Sdkman
if [ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]
then
  export SDKMAN_DIR="${HOME}/.sdkman"
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# Haskel
if [ -s "${HOME}/.ghcup/env" ]
then
  source "${HOME}/.ghcup/env"
fi
