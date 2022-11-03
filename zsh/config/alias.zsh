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
# Git push with upstream
alias gpp='git push --set-upstream origin ${$(git symbolic-ref HEAD)/refs\/heads\//}'

# Submodules
alias gsu='git submodule update --init --recursive'

# List git aliases
alias ghelp='bat ~/.zgen/robbyrussell/oh-my-zsh-master/plugins/git/git.plugin.zsh'

# Search through all branches
alias ggal="git branch -a | tr -d \* | sed '/->/d' | xargs git grep -HI"

# Statsh unstaged changes
alias gsti='git stash push --keep-index'

# Update HEAD to track divergence point from master
alias gbpr='git update-ref HEAD `git merge-base master HEAD`'

# Rebase with upstream branch (default master)
function grbf {
  local branch

  if [ $1 ]
  then
    branch=$1
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git rebase "${branch}"
}

# Merge with upstream branch (default master)
function gmf {
  local branch

  if [ $1 ]
  then
    branch=$1
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git merge "${branch}"
}

# Show remote status of branches
function gbgs {
  local tracked gone local terminator
  local show_tracked=1 show_gone=1 show_local=1
  case "${1}" in
    ''|-f|--full-color)
      tracked='[32m'
      gone='[31m'
      local='[34m'
      terminator='[m'
      ;;
    -s|--simple-color)
      tracked='[32mT[m '
      gone='[31mG[m '
      local='[34mL[m '
      terminator='[m'
      ;;
    -n|--no-color)
      tracked='T '
      gone='G '
      local='L '
      terminator=''
      ;;
    -t|--tracked)
      tracked=''
      gone=''
      local=''
      terminator=''
      unset show_gone
      unset show_local
      ;;
    -g|--gone)
      tracked=''
      gone=''
      local=''
      terminator=''
      unset show_tracked
      unset show_local
      ;;
    -l|--local)
      git branch --format "%(refname:short) %(upstream)" | awk '{if (!$2) print $1;}'
      return
      ;;
    *)
      echo 'Unknown parameter: '${@} >&2
      return 1
      ;;
  esac

  for branch in `git branch --format "%(refname:short):%(upstream)"`
  do
    lo=`cut -d':' -f1 <<<"${branch}"`;
    re=`cut -d':' -f2 <<<"${branch}"`;
    if [ "${re}" ]
    then
      if git rev-parse "${re}" &>/dev/null
      then
        [ $show_tracked ] && echo "${tracked}${lo}${terminator}" || true
      else
        [ $show_gone ] && echo "${gone}${lo}${terminator}" || true
      fi
    else
      [ $show_local ] && echo "${local}${lo}${terminator}" || true
    fi
  done
}

if command -v lazygit &> /dev/null
then
  alias lg=lazygit
fi

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

### Netstat for macos
[[ "$(uname)" == "Darwin" ]] && alias netst='lsof -nP -iTCP -sTCP:LISTEN'

### Pyenv
function penv {
  base="${HOME}/code/python/env"

  if [ "$1" ]
  then
    if [ "$1" = "-l" ]
    then
      newEnv="${PWD}/.venv"
    else
      newEnv="$1"
    fi
  else
    if [ -d "${PWD}/.venv" ]
    then
      newEnv="${PWD}/.venv"
    else
      newEnv="main"
    fi
  fi
  oldEnv="${VIRTUAL_ENV}"

  if [[ "${oldEnv}" != "${newEnv}" ]]
  then
    if command -v deactivate &> /dev/null
    then
      deactivate
    fi

    if ! [ "${newEnv}" = "${PWD}/.venv" ]
    then
      newEnv="${base}/${newEnv}"
    fi

    if [ ! -d "${newEnv}" ]
    then
      python3 -m virtualenv &> /dev/null
      if (( $? == 2 ))
      then
        module="virtualenv"
      else
        python3 -m venv &> /dev/null
        if (( $? == 2 ))
        then
          module="venv"
        fi
      fi

      if [ "${module}" ]
      then
        echo "Using \e[1m${module}\e[m"
        python3 -m "${module}" "${newEnv}" && \
        source "${newEnv}/bin/activate" && \
        python -m ensurepip && \
        python3 -m pip install --upgrade pip wheel setuptools && \
        echo "Virtual environment \e[1mcreated\e[m at \e[34m${newEnv}\e[m"
      else
        echo -e "\e[31mFailed to initialize virtual environemt\e[m"
        echo -e "\e[33mIs virtualenv installed?\e[m python3 -m pip install virtualenv"
        return -1
      fi
    else
      source "${newEnv}/bin/activate"
      echo "Virtual environment \e[1mset\e[m at \e[34m${newEnv}\e[m"
    fi

    if [[ ! `which python` =~ "${newEnv}/bin/*" ]]
    then
      echo -e "\e[31mFailed to switch virtual environment:\e[m python binary does not belong to ${newEnv})"
      deactivate
      return -1
    fi

    export PYENV_ROOT="${newEnv}"

    function exit() {
      deactivate && unset -f exit
    }
  fi
}

function _penv {
  if (( CURRENT == 2 ))
  then
    _path_files -W "${HOME}/code/python/env" -/
    if [ -d "./.venv" ]
    then
      local completion=('-l:Local venv')
      _describe 'venv' completion
    fi
  fi
}

compdef _penv penv

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
