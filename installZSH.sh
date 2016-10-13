#!/bin/bash

function fullPath {
  TARGET_FILE=$1

  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`

  # Compute the canonicalized name by finding the physical path 
  # for the directory we're in and appending the target file.
  PHYS_DIR=`pwd -P`
  RESULT=$PHYS_DIR/$TARGET_FILE
  RESULT=${RESULT%/.}
  echo $RESULT
}

function createSymlink {
  local OVERWRITE=false

  if [ -f "$1" ]
  then
    read -p "~/$1 already exists. Overwrite? [y/N] " INPUT
    case $INPUT in
      [Yy] )
        OVERWRITE=true
        ;;
    esac
  else
    OVERWRITE=true
  fi

  if [[ "$OVERWRITE" == "true" ]]
  then
    #############
    echo "ln -s $BASE_DIR/$1 $2"
  fi
}

BASE_DIR=$(dirname $(fullPath $0))
LAST_DIR=`pwd`
cd $HOME

# Install ZSH
which apt-get &> /dev/null
if [ $? ]
then
  PACKAGE_MANAGER="sudo apt-get"
else
  PACKAGE_MANAGER="brew"
fi

echo -n -e "\e[34mChecking ZSH.. [\e[m"
which zsh &> /dev/null
if [ $? ]
then
  echo -e "OK\e[34m]\e[m"
else
  echo -e "\e[31mFAIL\e[34m]\e[m"
  echo -e "\e[34mInstalling ZSH..\e[m"
  #############
  echo "$PACKAGE_MANAGER install zsh"

  if [ $? ]
  then
    echo -e "\e[31mCould not install ZSH!\e[m"
    exit
  fi
  echo -e "\e[32mDone!\e[m"
fi

echo -e "\e[34mSetting as main shell..\e[m"
#############
echo "chsh -s $(which zsh)"

if [ $? ]
then
  echo -e "\e[31mCould not set the main shell!\e[m"
  exit
fi
echo -e "\e[32mDone!\e[m"

## Oh My ZSH
echo -n -e "\e[34mChecking Oh My ZSH.. [\e[m"
if [ -f .oh-my-zsh ]
then
  echo -e "OK\e[34m]\e[m"
else
  echo -e "\e[31mFAIL\e[34m]\e[m"
  echo -e "\e[34mInstalling Oh My ZSH..\e[m"
  #############
  echo "curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
  echo -e "\e[32mDone!\e[m"
fi

# Make symlinks
echo -e "\e[34mMaking symlinks\e[m"
createSymlink ".aliasrc"
createSymlink ".zshrc"
createSymlink ".vimrc"
createSymlink simpalt.zsh-theme .oh-my-zsh/themes/

# ## Downloading dotfiles
# echo -e "\e[34mSetando the colors and the plugins..\e[m"
# sed -i 's~ZSH_THEME="robbyrussell"~ZSH_THEME="simpalt"~' ~/.zshrc
# echo "alias bd='cd -'" >> ~/.zshrc
# echo "alias vd='cd ..'" >> ~/.zshrc

# echo -e "\e[32mDone!\e[m"
# echo -e "\e[32mAgora sai desse terminal, que da proxima vez que vc abrir o terminal, o ZSH vai aparecer\e[m"
