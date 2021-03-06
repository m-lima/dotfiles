### General
alias mud='telnet www.ateraan.com 4002'
alias png='ping -c 4'

### Directory stuff
alias lt='ls -lathr'
alias l='ls -lah'
alias ll='ls -lh'

### Vim
if command -v nvim &> /dev/null
then
  alias vi=nvim
elif command -v vim &> /dev/null
then
  alias vi=vim
fi

### bat
if command -v batcat &> /dev/null
then
  alias bat=batcat
  alias bbat='batcat --paging=auto --style=auto'
fi

### Prompt expansion
pw() {
  [ $SIMPALT_SMALL ] && unset SIMPALT_SMALL || SIMPALT_SMALL='ON'
}

### Git stuff
alias gsu='git submodule update --init --recursive'
alias gpp='git push --set-upstream origin ${$(git symbolic-ref HEAD)/refs\/heads\//}'
alias gppf='git push --set-upstream origin +${$(git symbolic-ref HEAD)/refs\/heads\//}'
alias ghelp='cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh'
alias ggal="git branch -a | tr -d \* | sed '/->/d' | xargs git grep -HI"
alias gdc='git diff --cached'
alias gdb='git diff --stat'

### Copy path
if [[ "$(uname)" == "Darwin" ]]
then
  alias cpwd='echo -n "${PWD}" | pbcopy'
  alias ppwd='cd $(pbpaste)'
else
  if command -v xclip &> /dev/null
  then
    alias cpwd='echo -n "${PWD}" | xclip -se c'
    alias ppwd='cd $(xclip -o -se c)'
  else
    alias cpwd='pwd > /tmp/pwd_buffer_$USER'
    alias ppwd='cd "$(cat /tmp/pwd_buffer_$USER)" 2> /dev/null'
  fi
fi

### Pyenv
function penv {
  base="${HOME}/code/python/env"

  if [ "$1" ]
  then
    newEnv="$1"
  else
    newEnv="main"
  fi
  oldEnv="${VIRTUAL_ENV}"

  if [[ "${oldEnv}" != "${newEnv}" ]]
  then
    if command -v deactivate &> /dev/null
    then
      deactivate
    fi

    newEnv="${base}/${newEnv}"

    if [ ! -d "${newEnv}" ]
    then
      python3 -m venv "${newEnv}"
      source "${newEnv}/bin/activate"
      python -m ensurepip
      python3 -m pip install --upgrade pip
      echo "Virtual environment \x1b[1mcreated\x1b[m at $\x1b[34m${newEnv}\x1b[m"
    else
      source "${newEnv}/bin/activate"
      echo "Virtual environment \x1b[1mset\x1b[m at \x1b[34m${newEnv}\x1b[m"
    fi

    if [[ ! `which python` =~ "${newEnv}/bin/*" ]]
    then
      echo -e "\e[31mFailed to swithc virtual environment:\e[m python binary does not belong to ${newEnv}"
      deactivate
      return -1
    fi

    export PYENV_ROOT="${newEnv}"

    function exit() {
      deactivate && unset -f exit
    }
  fi
}

### Dictionary
function def {
  if [ "$1" ]
  then
    local word="dict://dict.org/d:"$1
    local return=$(curl $word 2> /dev/null | grep -v '[0-9][0-9][0-9] ')
    if [ $return ]
    then
        echo -e "\e[32m$return\e[m"
    else
      echo -e "\e[31mNo definition found\e[m"
    fi
  fi
}

### Ranger with pwd change
if command -v ranger &> /dev/null
then
  function rng {
    local tempfile="/tmp/pwd-from-ranger"
    ranger --choosedir=$tempfile $argv
    local rangerpwd=$(cat $tempfile)
    if [[ "$PWD" != $rangerpwd ]]
    then
      cd $rangerpwd
    fi
  }
fi

### Visual Studio Code from Mac CLI
if [ -d "/Applications/Visual Studio Code.app" ]
then
  alias vscode='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
fi

### Open with default opener
if command -v xdg-open &> /dev/null
then
  alias open='xdg-open'
fi

### Ripgrep
if command -v rg &> /dev/null
then
  alias rg='rg --smart-case'
fi

### Faster find
function fnd {
  if [ ! "${1}" ]
  then
    return -1
  fi

  local case="-name"
  local error=""
  local root="."
  local type=""
  local flags=${2}

  if [ "${flags}" ]
  then
    [[ "${flags}" == *i* ]] && case="-iname"
    [[ "${flags}" == *e* ]] && error="true"
    [[ "${flags}" == *r* ]] && root="/"
    [[ "${flags}" == *f* ]] && type=("-type" "f")
    [[ "${flags}" == *d* ]] && type=("-type" "d")
  fi

  if [ ${error} ]
  then
    find ${root} ${type} ${case} "${1}"
  else
    find ${root} ${type} ${case} "${1}" 2> /dev/null
  fi
}

function _fnd {
  if (( CURRENT == 3 ))
  then
    local flags=(
    'i[Case insensitive]'
    'e[Show errors]'
    '(d)f[Set type to directory]'
    '(f)d[Set type to file]'
    )
    _values -s '' 'flags' ${flags}
  fi
}

compdef _fnd fnd

### Commands to remember
## Code
# gource -c 3 <path>
# cloc --exclude-dir=ext,lib,build,node_modules,.git,.idea,nbproject --not-match-f='package-lock\.json' <path>
