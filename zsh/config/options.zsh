# Preferred editor for local and remote sessions
if [ `command -v nvim 2> /dev/null` ]
then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# History Substring Config
setopt HIST_IGNORE_ALL_DUPS

# Enable vim editing of command
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

export HISTSIZE=100000
export SAVEHIST=${HISTSIZE}

# Disable the auto cd'ing
unsetopt autocd
