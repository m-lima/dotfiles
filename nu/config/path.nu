# # Brew on M1
# if [ -s "/opt/homebrew/bin/brew" ]
# then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
#   export LIBRARY_PATH="${HOMEBREW_PREFIX}/lib${LIBRARY_PATH+:$LIBRARY_PATH}"
#   export CPATH="${HOMEBREW_PREFIX}/include${CPATH+:$CPATH}"
# fi
#
# # Rust
# if [ -s "${HOME}/.cargo/env" ]
# then
#   source "$HOME/.cargo/env"
# fi
#
# # Go
# if [ -d "${HOME}/code" ] && command -v go &> /dev/null
# then
#   export GOPATH="${HOME}/code/go/root"
#   export PATH="${GOPATH}/bin${PATH+:$PATH}"
# fi
#
# # Sdkman
# if [ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]
# then
#   export SDKMAN_DIR="${HOME}/.sdkman"
#   source "${SDKMAN_DIR}/bin/sdkman-init.sh"
# fi
#
# # Haskel
# if [ -s "${HOME}/.ghcup/env" ]
# then
#   source "${HOME}/.ghcup/env"
# else
#   if [ -d "${HOME}/.ghcup/bin" ]
#   then
#     export PATH="${HOME}/.ghcup/bin${PATH+:$PATH}"
#   fi
#   if [ -d "${HOME}/.cabal/bin" ]
#   then
#     export PATH="${HOME}/.cabal/bin${PATH+:$PATH}"
#   fi
# fi
#
# # Adding local bin to the top of the PATH
# # This is not just for precedence, but it is also used as a marker later on
# export PATH="${HOME}/bin${PATH+:$PATH}"
#
# let path_builder = [('~/bin' | path expand)]
#
# let path_builder = if ('~/.cargo/bin' | path exists) {  } else { [] }

let-env PATH = ($env.PATH | prepend ('~/bin' | path expand))

if ('~/.cargo/bin' | path exists) {
  let-env PATH = ($env.PATH | prepend ('~/.cargo/bin' | path expand))
}

if ('~/.cargo/bin' | path exists) {
  let-env PATH = ($env.PATH | prepend ('~/.cargo/bin' | path expand))
}