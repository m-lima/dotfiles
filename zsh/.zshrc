# Temp variables for control in local
local_plugins=()
local_pluginManager=zgen
local_zshFramework=omz

# Load local config
source "${HOME}/.config/m-lima/zsh/local.zsh"

# TODO: Remove this when not needed anymore
[ ! -z ${localPlugins+x} ] && echo "localPlugins is no longer in use. Use local_plugins instead"
[ ! -z ${pluginManager+x} ] && echo "pluginManager is no longer in use. Use local_pluginManager instead"
[ ! -z ${zshFramework+x} ] && echo "zshFramework is no longer in use. Use local_zshFramework instead"

# Load options
source "${HOME}/.config/m-lima/zsh/options.zsh"

# If using zgen, load plugins
source "${HOME}/.config/m-lima/zsh/plugins.zsh"

# Load the aliases
source "${HOME}/.config/m-lima/zsh/alias.zsh"

# If using iTerm2, set integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.config/m-lima/zsh/iterm.zsh"

# Clean up temporary variables
unset local_plugins
unset local_pluginManager
unset local_zshFramework

if ! command -v _fd &> /dev/null
then
  autoload -U compinit && compinit
fi

# Load final
source "${HOME}/.config/m-lima/zsh/final.zsh"
