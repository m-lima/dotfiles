#!/bin/bash

# TODO
# [O] git submodule
# [O] Generate tmux-powerlinerc
# [O] Edit tmux-powerlinerc with sed (spotify and theme)
# [X] Symlink tmux simpaltmux.sh theme
# [ ] Make simpaltmux.sh pretty
# [ ] Split .tmux.conf into shared and local

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

function install {
  local INSTALL=true

  read -p "Install $1? [Y/n] " INPUT
  case $INPUT in
    [Nn] )
      INSTALL=false
      ;;
  esac

  if [[ "$INSTALL" == "true" ]]
  then
    $2
    return $?
  fi

  return 1
}

function checkContinue {
  read -p "Continue? [yN] " INPUT
  case $INPUT in
    [Yy] )
      return 0;
      ;;
  esac

  exit
}

function installFile {
  local OVERWRITE=false

  if [ -f "$3$2" ]
  then
    read -p "$3$2 already exists. Overwrite? [y/N] " INPUT
    case $INPUT in
      [Yy] )
        rm "$3$2"
        OVERWRITE=true
        ;;
    esac
  else
    OVERWRITE=true
  fi

  if [[ "$OVERWRITE" == "true" ]]
  then
    if [[ "$1" == "s" ]]
    then
      return $(ln -s $BASE_DIR/$2 $3)
    else
      if [[ "$1" == "c" ]]
      then
        return $(cp $BASE_DIR/$2 $3)
      fi
    fi
  fi

  return 1
}

BASE_DIR=$(dirname $(fullPath $0))
pushd $HOME &> /dev/null

# Install ZSH
if [ $(command -v apt-get) ]
then
  PACKAGE_MANAGER="sudo apt-get -y"
  read -p "Update apt-get? [y/N] " INPUT
  case $INPUT in
    [Yy] )
      sudo apt-get update
      ;;
  esac
else
  PACKAGE_MANAGER="brew"
fi

echo -n "[34mChecking ZSH.. [[m"
if [[ "$SHELL" == */zsh ]]
then
  echo "[32mOK[34m][m"
else
  if [ $(command -v zsh) ]
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"
    echo "[34mInstalling ZSH..[m"

    if [ $(install ZSH "$PACKAGE_MANAGER install zsh") ]
    then
      echo "[31mCould not install ZSH![m"
      checkContinue
    else
      echo "[32mDone![m"
    fi
  fi

  read -p "Set ZSH as main shell (Skip if running Bash on Windows)? [y/N] " INPUT
  case $INPUT in
    [Yy] )
      echo "[34mSetting as main shell..[m"

      if [ $(chsh -s $(which zsh)) ]
      then
        echo "[31mCould not set the main shell![m"
        checkContinue
      else
        echo "[32mDone![m"
      fi
      ;;
  esac

fi

## Oh My ZSH
echo -n "[34mChecking Oh My ZSH.. [[m"
if [ -d .oh-my-zsh ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling Oh My ZSH..[m"

  if [ $(install "Oh My ZSH" "curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh") ]
  then
    echo "[31mCould not install Oh My ZSH![m"
    checkContinue
  else
    echo "[32mDone![m"
  fi
fi

## TMUX
echo -n "[34mChecking TMUX.. [[m"
if [ $(command -v tmux) ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling TMUX..[m"

  if [ $(install TMUX "$PACKAGE_MANAGER install tmux") ]
  then
    echo "[31mCould not install TMUX![m"
    checkContinue
  else
    echo "[32mDone![m"
  fi
fi

## TMUX Powerline
echo -n "[34mChecking TMUX Powerline.. [[m"
if [ -f .tmux-powerlinerc ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mGenerating tmux-powerlinerc..[m"

  cd $BASE_DIR &> /dev/null
  git submodule update --init --recursive
  tmux-powerline/generate_rc.sh > /dev/null
  cd $HOME &> /dev/null
  mv .tmux-powerlinerc.default .tmux-powerlinerc
  sed -i "s~export TMUX_POWERLINE_THEME=\"default\"~export TMUX_POWERLINE_THEME=\"simpaltmux\"~" .tmux-powerlinerc
  sed -i "s~export TMUX_POWERLINE_DIR_USER_THEMES=\"\"~TMUX_POWERLINE_DIR_USER_THEMES=\"$BASE_DIR\"~" .tmux-powerlinerc
  sed -i "s~export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER=\"\"~export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER=\"spotify\"~" .tmux-powerlinerc
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

  if [ $(install Vim "$PACKAGE_MANAGER install vim") ]
  then
    echo "[31mCould not install Vim![m"
    checkContinue
  else
    echo "[32mDone![m"
  fi
fi

echo -n "[34mChecking Vundle.. [[m"
if [ -d .vim/bundle/Vundle.vim ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mInstalling Vundle..[m"

  if [ $(install Vundle "git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim") ]
  then
    echo "[31mCould not install Vundle![m"
    checkContinue
  else
    echo "[32mDone![m"
  fi
fi

# Create ~/bin
echo -n "[34mChecking bin folder.. [[m"
if [ -d bin ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mCreating folder..[m"

  if [ mkdir bin &> /dev/null ]
  then
    echo "[31mCould not create bin folder![m"
    checkContinue
  else
    echo "[32mDone![m"
  fi
fi

# Make symlinks
echo "[34mMaking symlinks[m"
installFile s ".aliasrc"
installFile s ".zshrc"
installFile s ".vimrc"
installFile s ".vimrc.base"
installFile s "tmx" bin/
installFile s simpalt.zsh-theme .oh-my-zsh/themes/

echo "[34mCopying files[m"

if installFile c ".tmux.conf" ./
then
  echo "set-option -g default-shell $(which zsh)" >> .tmux.conf
  echo "set-option -g status-left \"#($BASE_DIR/tmux-powerline/powerline.sh left)\"" >> .tmux.conf
  echo "set-option -g status-right \"#($BASE_DIR/tmux-powerline/powerline.sh right)\"" >> .tmux.conf
fi

if installFile c ".zshrc.local" ./
then
  vi .zshrc.local
fi

popd &> /dev/null
