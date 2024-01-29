### General
alias mud='telnet www.ateraan.com 4002'
alias png='ping -c 4'

### Directory stuff
alias lt='ls -lathr'
alias l='ls -lAhv'
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
fi
if command -v bat &> /dev/null
then
  alias bbat='bat --paging=auto --style=auto'
fi

### Prompt expansion
pw() {
  [ $SIMPALT_SMALL ] && unset SIMPALT_SMALL || SIMPALT_SMALL='ON'
}

### kubectl
if command -v kubectl &> /dev/null
then
  alias k=kubectl
fi

### Git stuff
## Matching nushell
# Branch
alias gb='git branch'

# Commit
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gcm='git commit --amend --no-edit'

# Clone
alias gcl='git clone --recurse-submodules'

# Diff
alias gd='git diff'
alias gds='git diff --staged'

# Fetch
alias gfa='git fetch --all --prune --jobs=10'

# Push/Pull
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpp='git push --set-upstream origin ${$(git symbolic-ref HEAD)/refs\/heads\//}' # Git push with upstream

# Stash
alias gs='git stash'

# Status
alias gsb='git status -sb'

# Submodules
alias gsu='git submodule update --init --recursive'

# Checkout
alias gt='git checkout'
alias gtb='git checkout -b'

## Exclusive for zsh
# List git aliases
alias ghelp='bat ~/.zgen/robbyrussell/oh-my-zsh-master/plugins/git/git.plugin.zsh'

# Search through all branches
alias ggal="git branch -a | tr -d \* | sed '/->/d' | xargs git grep -HI"

# Stash unstaged changes
alias gsti='git stash push --keep-index'

# Update HEAD to track divergence point from master
alias gbpr='git reset `git merge-base master HEAD`'

# Show remote status of branches
unalias gbs
function gbs {
  local tracked gone local remote terminator
  local show_tracked=1 show_gone=1 show_local=1 show_remote=1
  local trackeds=()
  case "${1}" in
    ''|-f|--full-color)
      tracked='[32m'
      gone='[31m'
      local='[34m'
      remote='[35m'
      terminator='[m'
      ;;
    -fl|--full-color-local)
      tracked='[32m'
      gone='[31m'
      local='[34m'
      terminator='[m'
      unset remote show_remote
      ;;
    -s|--simple-color)
      tracked='[32mT[m '
      gone='[31mG[m '
      local='[34mL[m '
      remote='[35mR[m '
      terminator='[m'
      ;;
    -sl|--simple-color-local)
      tracked='[32mT[m '
      gone='[31mG[m '
      local='[34mL[m '
      terminator='[m'
      unset remote show_remote
      ;;
    -n|--no-color)
      tracked='T '
      gone='G '
      local='L '
      remote='R '
      unset terminator
      ;;
    -nl|--no-color-local)
      tracked='T '
      gone='G '
      local='L '
      unset terminator remote show_remote
      ;;
    -t|--tracked)
      unset tracked gone local remote terminator              show_gone show_local show_remote
      ;;
    -g|--gone)
      unset tracked gone local remote terminator show_tracked           show_local show_remote
      ;;
    -r|--remote)
      unset tracked gone local remote terminator show_tracked show_gone show_local
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

  for branch in $(git branch --format "%(refname:short):%(upstream)"); do
    lo=$(cut -d':' -f1 <<<"${branch}")
    re=$(cut -d':' -f2 <<<"${branch}")
    if [ "${re}" ]; then
      if git rev-parse "${re}" &>/dev/null; then
        if [ $show_tracked ]; then
          echo "${tracked}${lo}${terminator}"
          trackeds+="${re#refs/remotes/}"
        fi
      else
        [ $show_gone ] && echo "${gone}${lo}${terminator}" || true
      fi
    else
      [ $show_local ] && echo "${local}${lo}${terminator}" || true
    fi
  done

  if [ "${show_remote}" ]; then
    local remotes=($(git remote show))

    for branch in $(git branch -r --format "%(refname:short)"); do
      if [[ "${branch}" != *"/HEAD" ]]; then
        not_tracked=1
        for tracked in ${trackeds}; do
          if [[ "${branch}" == "${tracked}" ]]; then
            unset not_tracked
            break
          fi
        done
        [ $not_tracked ] && echo "${remote}${branch}${terminator}" || true
      fi
    done
  fi
}

# Rebase with upstream branch (default master)
function gfr {
  local branch

  if [ $1 ]
  then
    if [[ "${1}" == "-s" ]]
    then
      branch="origin/$(git symbolic-ref --short HEAD)"
    else
      branch="origin/${1}"
    fi
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git rebase "${branch}"
}

# Merge with upstream branch (default master)
function gfm {
  local branch

  if [ $1 ]
  then
    branch="origin/${1}"
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git merge "${branch}"
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
  alias rgc='rg -U "^\\s*//[^/][^\\n]*\\n\\s*//[^/\\n]*\\n"'
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
