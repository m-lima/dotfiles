# Adding local bin to path
export PATH="$HOME"/bin:$PATH

# Preferred editor for local and remote sessions
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [[ $TERM = xterm* ]]
then
  export TERM=xterm-256color
fi

# History Substring Config
setopt HIST_IGNORE_ALL_DUPS
