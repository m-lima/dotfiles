# Shared plugins
plugins+=(git colorize nali)
plugins+=(zsh-autosuggestions)

# plugins+=(history-substring-search)
# plugins+=(vi-mode)
# plugins+=(zsh-vim-mode)

# Load local config
source "$HOME"/.zshrc.local

# Path oh-my-zsh installation.
export ZSH="$HOME"/.oh-my-zsh

# ZSH options
ZSH_THEME="simpalt"
# HYPHEN_INSENSITIVE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Adding local bin to path
export PATH="$HOME"/bin:$PATH

# Setting UTF8 locale
# export LC_ALL="en_US.UTF-8"
## NOT TO BE USED
## Use `localectl set-locale LANG=en_US.UTF-8`

if [[ $TERM = xterm* ]]
then
  export TERM=xterm-256color
fi

# Enable vim mode
# bindkey -v


# History Substring Config
setopt HIST_IGNORE_ALL_DUPS
