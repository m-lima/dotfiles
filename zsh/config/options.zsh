# Adding local bin to path
export PATH="$HOME"/bin:$PATH

# Preferred editor for local and remote sessions
export EDITOR='vim'

if [[ $TERM = xterm* ]]
then
  export TERM=xterm-256color
fi

# History Substring Config
setopt HIST_IGNORE_ALL_DUPS
