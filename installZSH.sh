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
    ln -s $BASE_DIR/$1 $2
  fi
}

BASE_DIR=$(dirname $(fullPath $0))
LAST_DIR=`pwd`
cd $HOME

# Install ZSH
if [ $(command -v apt-get) ]
then
  PACKAGE_MANAGER="sudo apt-get"
else
  PACKAGE_MANAGER="brew"
fi

echo -n "[34mChecking ZSH.. [[m"
if [[ "$SHELL" == "/bin/zsh" ]]
then
  echo "[32mOK[34m][m"
else
  if [ $(command -v zsh) ]
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"
    echo "[34mInstalling ZSH..[m"
    $PACKAGE_MANAGER install zsh

    if [ $? ]
    then
      echo "[31mCould not install ZSH![m"
      exit
    fi
    echo "[32mDone![m"
  fi

  echo "[34mSetting as main shell..[m"
  chsh -s $(which zsh)

  if [ $? ]
  then
    echo "[31mCould not set the main shell![m"
    exit
  fi
  echo "[32mDone![m"
fi

## Oh My ZSH
echo -n "[34mChecking Oh My ZSH.. [[m"
if [ -d .oh-my-zsh ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling Oh My ZSH..[m"
  curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
  echo "[32mDone![m"
fi

## Vim/Vundle
echo -n "[34mChecking Vim.. [[m"
if [ $(command -v vim) ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling Vim..[m"
  $PACKAGE_MANAGER install vim

  if [ $? ]
  then
    echo "[31mCould not install Vim![m"
    exit
  fi
  echo "[32mDone![m"
fi

echo -n "[34mChecking Vundle.. [[m"
if [ -d .vim/bundle/Vundle.vim ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling Vundle..[m"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  if [ $? ]
  then
    echo "[31mCould not install Vundle![m"
    exit
  fi
  echo "[32mDone![m"
fi

# Make symlinks
echo "[34mMaking symlinks[m"
createSymlink ".aliasrc"
createSymlink ".zshrc"
createSymlink ".vimrc"
createSymlink ".tmux.conf"
createSymlink simpalt.zsh-theme .oh-my-zsh/themes/

popd
