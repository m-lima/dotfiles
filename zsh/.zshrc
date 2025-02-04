# Restore our path to the top of the stack (needed for OSX and Arch, e.g.)
system_path="${PATH%":${HOME}/bin"*}"
export PATH="${${PATH#"$system_path"}:1}"
export PATH="${PATH:+$PATH:}${system_path}"
unset system_path

# Temp variables for control in local
local_plugins=()
local_pluginManager=zgen
local_zshFramework=omz

# Load local config
source ~/.config/m-lima/zsh/local.zsh

# If using zgen, load plugins
source ~/.config/m-lima/zsh/plugins.zsh

# Load options
source ~/.config/m-lima/zsh/options.zsh

# Load the aliases
source ~/.config/m-lima/zsh/alias.zsh

# If using iTerm2, set integration
test -e ~/.iterm2_shell_integration.zsh && source ~/.config/m-lima/zsh/iterm.zsh

# Clean up temporary variables
unset local_plugins
unset local_pluginManager
unset local_zshFramework

if ! command -v _fd &> /dev/null
then
  autoload -U compinit && compinit
fi

# Load final
source ~/.config/m-lima/zsh/final.zsh
