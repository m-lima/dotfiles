#!/bin/bash

# TODO
# [O] git submodule
# [O] Generate tmux-powerlinerc
# [O] Edit tmux-powerlinerc with sed (spotify and theme)
# [O] Symlink tmux simpaltmux.sh theme
# [O] Make simpaltmux.sh pretty
# [O] Split .tmux.conf into shared and local
# [ ] Ask if force regenerate tmux-powerlinerc
# [O] Ask if force regenerate tmux.conf.local
# [ ] Add roll to TMUX powerline
# [ ] Show no definition found on powershell

################################################################################
# Functions                                                                    #
################################################################################

################################################################################
# Gets the full path to a relative path
#
# arg1: The path to be converted into absolute
# return: The full path

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

################################################################################
# Shows a prompt to confirm continuation. Aborts the script if cancelled
#
# return: Success if accepted. Will abort if cancelled

function checkContinue {
  read -p "Continue? [y/N] " INPUT
  case $INPUT in
    [Yy] )
      return 0;
      ;;
  esac

  exit
}

################################################################################
# Checks and installs a package.
#
# arg1: Friendly name for the package
# arg2: Package install command
# arg3: The conditions to check if the package is intalled
# return: Abort if cancelled, or success otherwise

function checkInstall {
  echo -n "[34mChecking $1.. [[m"
  if eval $3
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    read -p "Install $1? [Y/n] " INPUT
    case $INPUT in
      [Nn] )
        checkContinue
        return 1
        ;;
      *)
        if eval "$2"
        then
          echo "[32mDone![m"
        else
          echo "[31mCould not install $1![m"
          checkContinue
          return 1
        fi
        ;;
    esac
  fi

  return 0
}

################################################################################
# Helper function. Since most of the calls to checkInstall are similar
# this function autogenerates the arguments
#
# arg1: Name of the package
# return: Abort if cancelled, or success otherwise

function checkInstallDefault {
  checkString='[ $(command -v '"$1"') ]'
  checkInstall $1 "$PACKAGE_INSTALL $1" "$checkString"
}

################################################################################
# Installs a file. The installation might be a copy or a symlink
# The target file is checked for existence and a prompt will ask if it should
# be overwritten
#
# arg1: Either "s" or "c" for symlink or copy, respectively
# arg2: The target folder location
# arg3: The source file
# [arg4]: Installation path.
# return: Failure if cancelled, or status code of install operation

function installFile {
  echo "[34mInstalling $3..[m"
  if [ -z "$4" ]
  then
    INSTALL_PATH="$HOME"/
  else
    INSTALL_PATH="$HOME"/"$4"/
  fi

  local OVERWRITE=false

  if [ -f "$INSTALL_PATH$3" ]
  then
    read -p "$INSTALL_PATH$3 already exists. Overwrite? [y/N] " INPUT
    case $INPUT in
      [Yy] )
        rm "$INSTALL_PATH$3"
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
      ln -sf $BASE_DIR/$2/$3 $INSTALL_PATH
    elif [[ "$1" == "c" ]]
    then
      cp $BASE_DIR/$2/$3 $INSTALL_PATH
    else
      return 1
    fi
  else
    return 1
  fi
}

################################################################################
# Installs a file. The installation might be a copy or a symlink
# The target file is checked for existence and a prompt will ask if it should
# be overwritten
#
# arg1: Either "s" or "c" for symlink or copy, respectively
# arg2: The source file
# arg3: Installation path. Should end with /
# return: Failure if cancelled, or status code of install operation

function installPacaur {
  read -p "Install pacaur? [Y/n] " INPUT
  case $INPUT in
    [Nn] )
      return 0
      ;;
  esac

  if ! checkInstallDefault git
  then
    return 1
  fi
  GIT_INSTALLED=1

  sudo pacman -S base-devel fakeroot jshon expac yajl

  rm -rf /tmp/dotfile_pacaur_install 2> /dev/null
  mkdir /tmp/dotfile_pacaur_install

  cd /tmp/dotfile_pacaur_install
  if git clone https://aur.archlinux.org/cower.git
  then
    cd cower
    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
    makepkg && sudo pacman --noconfirm -U *.tar.xz
  fi

  cd /tmp/dotfile_pacaur_install
  if ! git clone https://aur.archlinux.org/pacaur.git
  then
    return 1
  fi

  cd pacaur
  if makepkg && sudo pacman --noconfirm -U *.tar.xz
  then
    echo "[34mUsing pacaur[m"
    PACKAGE_INSTALL="pacaur --noedit --noconfirm -S"
    return 0
  else
    return 1
  fi
}

################################################################################
# Script start                                                                 #
################################################################################

########################################
# Get location of files
BASE_DIR=$(dirname $(fullPath $0))

########################################
# Check sudo
if [ ! $(command -v sudo) ]
then
  echo "[31msudo not found[m"
  echo "Please install it as super user before continuing"
  exit
fi

########################################
# Determine package manager
echo -n "[34mChecking package manager.. [[m"
if [ $(command -v apt-get) ]
then
  echo "[32mapt-get[34m][m"
  PACKAGE_INSTALL="sudo apt-get -y install"

elif [ $(command -v pacaur) ]
then
  echo "[32mpacaur[34m][m"
  PACKAGE_INSTALL="pacaur --noedit --noconfirm -S"

elif [ $(command -v pacman) ]
then
  echo "[32mpacman[34m][m"
  PACKAGE_INSTALL="sudo pacman --noconfirm -S"

elif [ $(command -v brew) ]
then
  echo "[32mbrew[34m][m"
  PACKAGE_INSTALL="brew install"

else
  echo "[31mFAIL[34m][m"
  echo "[31mCould not determine package manager[m"
  exit
fi

########################################
# Suggest pacaur
if [[ "$PACKAGE_INSTALL" == "sudo pacman --noconfirm -S" ]] && ! installPacaur
then
  echo "[31mCould not install pacaur![m"
  read -p "Continue using pacman? [Y/n] " CONTINUE
  case $CONTINUE in
    [Nn] )
      exit
      ;;
  esac
fi

cd $HOME

########################################
# Install git
[ -z $GIT_INSTALLED ] && checkInstallDefault git

########################################
# Install curl
checkInstallDefault curl

########################################
# Install vim
checkInstallDefault vim

########################################
# Install Vundle
checkInstall "Vundle" 'git clone https://github.com/VundleVim/Vundle.vim.git "$HOME"/.vim/bundle/Vundle.vim' '[ -d "$HOME"/.vim/bundle/Vundle.vim ]'

########################################
# Install tmux
if checkInstallDefault tmux
then
  echo -n "[34mChecking TMUX Powerline.. [[m"
  if [ -f "$HOME"/.tmux-powerlinerc ]
  then
    echo "[32mOK[34m][m"
    FORCE=false
    read -p "Force generation? [y/N] " INPUT
    case $INPUT in
      [Yy] )
        FORCE=true
        ;;
    esac
  else
    echo "[31mFAIL[34m][m"
    FORCE=true
  fi

  if [[ "$FORCE" == "true" ]]
  then
    echo "[34mGenerating tmux-powerlinerc..[m"

    cd $BASE_DIR/tmux
    git submodule update --init --recursive
    tmux-powerline/generate_rc.sh > /dev/null
    cd $HOME
    mv .tmux-powerlinerc.default .tmux-powerlinerc
    sed -i'' -e "s~export TMUX_POWERLINE_THEME=\"default\"~export TMUX_POWERLINE_THEME=\"simpaltmux\"~; s~export TMUX_POWERLINE_DIR_USER_THEMES=\"\"~TMUX_POWERLINE_DIR_USER_THEMES=\"$BASE_DIR/tmux/\"~; s~export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER=\"\"~export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER=\"spotify\"~" .tmux-powerlinerc
    echo "[32mDone![m"
  fi
fi

########################################
# Install ZSH
if checkInstallDefault zsh
then
  echo -n "[34mChecking default shell.. [[m"
  if [[ "$SHELL" == */zsh ]]
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    read -p "Set ZSH as main shell (Skip if running Bash on Windows)? [y/N] " INPUT
    case $INPUT in
      [Yy] )
        echo "[34mSetting as main shell..[m"

        if chsh -s $(which zsh)
        then
          echo "[32mDone![m"
          export SHELL=zsh
        else
          echo "[31mCould not set the main shell![m"
          checkContinue
        fi
        ;;
    esac
  fi
fi

########################################
# Install Oh My ZSH
checkInstall "Oh My ZSH" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"' '[ -d "$HOME"/.oh-my-zsh ]'

########################################
# Create ~/bin
echo -n "[34mChecking bin folder.. [[m"
if [ -d "$HOME"/bin ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mCreating folder..[m"

  if mkdir "$HOME"/bin &> /dev/null
  then
    echo "[32mDone![m"
  else
    echo "[31mCould not create bin folder![m"
    checkContinue
  fi
fi

########################################
# Make symlinks
echo "[34mMaking symlinks..[m"
installFile s zsh .aliasrc
installFile s zsh .zshrc
installFile s vim .vimrc
installFile s vim .vimrc.base
installFile s scripts tmx bin
installFile s tmux .tmux.conf
installFile s zsh simpalt.zsh-theme .oh-my-zsh/themes

########################################
# Copy files
echo "[34mCopying files..[m"

if installFile c tmux .tmux.conf.local
then
  echo "set-option -g default-shell $(which zsh)" >> "$HOME"/.tmux.conf.local
  echo "set-option -g status-left \"#($BASE_DIR/tmux/tmux-powerline/powerline.sh left)\"" >> "$HOME"/.tmux.conf.local
  echo "set-option -g status-right \"#($BASE_DIR/tmux/tmux-powerline/powerline.sh right)\"" >> "$HOME"/.tmux.conf.local
fi

if installFile c zsh .zshrc.local
then
  if [[ "$PACKAGE_INSTALL" == "pacaur --noedit --noconfirm -S" ]]
  then
    echo 'alias pc=pacaur' >> "$HOME"/.zshrc.local
  fi
  vim "$HOME"/.zshrc.local
fi

########################################
# Setup locale
echo "[34mDownloading font..[m"
read -p "Download DejaVu Sans for Powerline? [y/N]" INPUT
case $INPUT in
  [Yy] )
    cd "$HOME"
    curl -s -L 'https://raw.githubusercontent.com/powerline/fonts/master/DejaVuSansMono/DejaVu Sans Mono for Powerline.ttf' -o "$HOME/DejaVu Sans Mono for Powerline.ttf" && echo "[32mFont saved as $HOME/DejaVu Sans Mono for Powerline.ttf[m"
    ;;
esac
