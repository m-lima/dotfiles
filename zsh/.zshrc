# Shared plugins
plugins+=(git colorize nali)
# plugins+=(zsh-autosuggestions)
plugins+=(nali-autosuggestions)

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

# Load the aliases
source "${HOME}"/.aliasrc

# Enable vim mode
# bindkey -v

# If using iTerm2, set integration
if test -e "${HOME}/.iterm2_shell_integration.zsh"
then
  source "${HOME}/.iterm2_shell_integration.zsh"

  function buildGitStatusLabel {
    _STATUS=""

    # check status of files
    _INDEX=$(command git status --porcelain 2> /dev/null)
    if [[ -n "$_INDEX" ]]; then
      if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
        # Staged
        _STATUS="$_STATUS📦"
      fi
      if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
        # Unstaged
        _STATUS="$_STATUS🤖"
      fi
      if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
        # Untracked
        _STATUS="$_STATUS✨"
      fi
      if $(echo "$_INDEX" | command grep -q '^UU '); then
        # Unmerged
        _STATUS="$_STATUS⛔️"
      fi
    else
      # Clean
      _STATUS="$_STATUS✅"
    fi

    # check status of local repository
    _INDEX=$(command git status --porcelain -b 2> /dev/null)
    if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
      # Ahead
      _STATUS="$_STATUS🚀"
    fi
    if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
      # Behind
      _STATUS="$_STATUS🐌"
    fi
    if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
      # Diverged
      _STATUS="$_STATUS😱"
    fi

    if $(command git rev-parse --verify refs/stash &> /dev/null); then
      # Stashed
      _STATUS="$_STATUS💾"
    fi

    echo $_STATUS

  }

  function iterm2_print_user_vars() {
    local ref dirty customLabel customGit

    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
      ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="‼️$(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
      # customLabel="${customLabel} : ${ref/refs\/heads\//} $(buildGitStatusLabel)"
      customLabel="${ref/refs\/heads\//} $(buildGitStatusLabel)"
    else
      customLabel=$(pwd | sed -e "s,^$HOME,~," | sed "s@\(.\)[^/]*/@\1/@g")
    fi

    "${HOME}/.iterm2/it2setkeylabel" set status "$customLabel"
  }
fi

