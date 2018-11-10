### General
alias jsn='python -m json.tool'
alias mud='telnet www.ateraan.com 4002'
alias png='ping -c 4'

### Directory stuff
alias lt='ls -lathr'
# alias l='ls -lah'
# alias ll='ls -lh'

### Vim
if [ $(command -v nvim) ]
then
  alias vi=nvim
elif [ $(command -v vim) ]
then
  alias vi=vim
fi

### Git stuff
alias gsu='git submodule update --init --recursive'
alias gpp='git push --set-upstream origin ${$(git symbolic-ref HEAD)/refs\/heads\//}'
alias gppf='git push --set-upstream origin +${$(git symbolic-ref HEAD)/refs\/heads\//}'
alias ghelp='cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh'
alias ggal="git branch -a | tr -d \* | sed '/->/d' | xargs git grep -HI"
alias gdc="git diff --cached"

### Copy path
if [[ "$(uname)" == "Darwin" ]]
then
  alias cpwd='pwd | pbcopy'
  alias ppwd='cd $(pbpaste)'
else
  if [ $(command -v xclip) ]; then
    alias cpwd='pwd | xclip'
    alias ppwd='cd $(xclip -o)'
  else
    alias cpwd='pwd > /tmp/pwd_buffer_$USER'
    alias ppwd='cd "$(cat /tmp/pwd_buffer_$USER)" 2> /dev/null'
  fi
fi

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
function rg {
  local tempfile="/tmp/pwd-from-ranger"
  ranger --choosedir=$tempfile $argv
  local rangerpwd=$(cat $tempfile)
  if [[ "$PWD" != $rangerpwd ]]
  then
    cd $rangerpwd
  fi
}

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
