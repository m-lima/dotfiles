# Load options
source "${HOME}/.config/m-lima/zsh/options.zsh"

# Load local config
source "${HOME}/.config/m-lima/zsh/local.zsh"

# Load plugins
source "${HOME}/.config/m-lima/zsh/plugins.zsh"

# Load the aliases
source "${HOME}/.config/m-lima/zsh/alias.zsh"

# If using iTerm2, set integration
if test -e "${HOME}/.iterm2_shell_integration.zsh"
then
  source "${HOME}/.config/m-lima/zsh/iterm.zsh"
fi
