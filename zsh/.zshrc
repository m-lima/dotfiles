# Load options
source "${HOME}/.config/m-lima/zsh/options.zsh"

# Load local config
source "${HOME}/.config/m-lima/zsh/local.zsh"

# If using zgen, load plugins
[ -d "${HOME}/.zgen" ] && source "${HOME}/.config/m-lima/zsh/plugins.zsh"

# Load the aliases
source "${HOME}/.config/m-lima/zsh/alias.zsh"

# If using iTerm2, set integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.config/m-lima/zsh/iterm.zsh"

# Clean up temporary variables
unset pluginManager
unset localPlugins
