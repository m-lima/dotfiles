### General
alias jsn='python -m json.tool'
alias mud='telnet www.ateraan.com 4002'
alias png='ping -c 4'

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

### Directory stuff
# alias l='ls -lah'
# alias ll='ls -lh'
alias lt='ls -lathr'

### Commands to remember
## Code
# gource -c 3 <path>
# cloc --exclude-dir=ext,lib,build,node_modules,.git,.idea,nbproject --not-match-f='package-lock\.json' <path>