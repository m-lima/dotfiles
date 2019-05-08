# Load options
source "${HOME}/.config/m-lima/zsh/options.zsh"

# Load local config
source "${HOME}/.config/m-lima/zsh/local.zsh"

# If using zgen, load plugins
source "${HOME}/.config/m-lima/zsh/plugins.zsh"

# Load the aliases
source "${HOME}/.config/m-lima/zsh/alias.zsh"

# If using iTerm2, set integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.config/m-lima/zsh/iterm.zsh"

# Clean up temporary variables
unset pluginManager
unset zshFramework
unset localPlugins

# If using sdkman
if [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]
then
  export SDKMAN_DIR="${HOME}/.sdkman"
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

if ! command -v _fd &> /dev/null
then
  autoload -U compinit && compinit
fi
