### General
alias mud='telnet www.ateraan.com 4002'
alias png='ping -c 4'

### Directory stuff
source ~/.config/m-lima/zsh/programs/ls.zsh

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

### Fd
if which -p fdfind &> /dev/null
then
  alias ff='fdfind'
fi

### Ripgrep
if command -v rg &> /dev/null
then
  alias rg='rg --smart-case'
  alias rgc='rg -U "^\\s*//[^/][^\\n]*\\n\\s*//[^/\\n]*\\n"'
fi

### Git stuff
alias ghelp='bat ~/.zgen/robbyrussell/oh-my-zsh-master/plugins/git/git.plugin.zsh'
unalias gbs
source ~/.config/m-lima/zsh/programs/git.zsh

if command -v lazygit &> /dev/null
then
  source ~/.config/m-lima/zsh/programs/lazygit.zsh
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

  if [ "${1}" ]
  then
    if [[ "${1}" == -* ]]
    then
      if [ "${1}" = "-l" ]
      then
        newEnv="${PWD}/.venv"
      else
        echo -e "\e[31mUnknown flag\e[m ${1}"
        return -1
      fi
    else
      newEnv="${1}"
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
      if command -v virtualenv &> /dev/null
      then
        module="virtualenv"
      else
        python3 -m virtualenv &> /dev/null
        if (( $? == 2 ))
        then
          module="python3 -m virtualenv"
        else
          python3 -m venv &> /dev/null
          if (( $? == 2 ))
          then
            module="python3 -m venv"
          fi
        fi
      fi

      if [ "${module}" ]
      then
        echo "Using \e[1m${module}\e[m"
        ${module} "${newEnv}" && \
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

    if [[ ! $(which python) =~ "${newEnv}/bin/*" ]]
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
  if [ "${1}" ]
  then
    local word="dict://dict.org/d:${1}"
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

### Commands to remember
## Code
# gource -c 3 <path>
# cloc --exclude-dir=ext,lib,build,node_modules,.git,.idea,nbproject --not-match-f='package-lock\.json' <path>
