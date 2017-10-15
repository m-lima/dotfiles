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
# [ ] Allow for neovim instead of vim
# [ ] Adapt vimrc to new rc format
# [ ] Configure clang-complete based on local environment

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
  if [ ! -z "$1" ]
  then
    echo "[31m$1[m"
  fi

  echo -n "Continue? [y/N] "
  read INPUT
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
# arg3: The conditions to check if the package is installed
# return: Abort if cancelled, or success otherwise

function checkInstall {
  echo -n "[34mChecking $1.. [[m"
  if eval $3
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    echo -n "Install $1? [Y/n] "
    read INPUT
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
          checkContinue "Could not install $1!"
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

  if [ ! -d $INSTALL_PATH ]
  then
    echo -n "$INSTALL_PATH does not exist. Create? [Y/n] "
    read INPUT
    case $INPUT in
      [Nn] )
        checkContinue
        return 1
        ;;
      * ) mkdir -p "$INSTALL_PATH" ;;
    esac
  fi

  if [ -f "$INSTALL_PATH$3" ] || [ -d "$INSTALL_PATH$3" ]
  then
    echo -n "$INSTALL_PATH$3 already exists. Overwrite? [y/N] "
    read INPUT
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
  echo -n "Install pacaur? [Y/n] "
  read INPUT
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

  $SU_DO pacman -S base-devel fakeroot jshon expac yajl

  rm -rf /tmp/dotfile_pacaur_install 2> /dev/null
  mkdir /tmp/dotfile_pacaur_install

  cd /tmp/dotfile_pacaur_install
  if git clone https://aur.archlinux.org/cower.git
  then
    cd cower
    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
    makepkg && $SU_DO pacman --noconfirm -U *.tar.xz
  fi

  cd /tmp/dotfile_pacaur_install
  if ! git clone https://aur.archlinux.org/pacaur.git
  then
    return 1
  fi

  cd pacaur
  if makepkg && $SU_DO pacman --noconfirm -U *.tar.xz
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
# Variables
BASE_DIR=$(dirname $(fullPath $0))
SU_DO=""
SYS_TYPE=""

########################################
# Check OS
echo -n "[34mChecking OS.. [[m"
case `uname -v` in
  *Ubuntu*) SYS_TYPE="Ubuntu";;
  *FreeBSD*) SYS_TYPE="FreeBSD";;
  *Darwin*) SYS_TYPE="Darwin";;
  *Microsoft*) SYS_TYPE="Bash on Windows";;
  *)
    case `uname -a` in
      *ARCH*) SYS_TYPE="Arch";;
      *Android*) SYS_TYPE="Android";;
      *) SYS_TYPE="";;
    esac
esac

if [ -z "$SYS_TYPE" ]
then
  echo "[31mFAIL[34m][m"
  SEL_SYS_TYPE=Y
else
  echo "[32m$SYS_TYPE[34m][m"
  echo -n "Choose a different OS? [y/N] "
  read SEL_SYS_TYPE
fi

case $SEL_SYS_TYPE in
  [Yy] )
    echo "[33mSelect your OS[m"
    echo "[[33mU[m]buntu"
    echo "[[33mF[m]ree BSD"
    echo "[[33mD[m]arwin"
    echo "A[[33mn[m]droid"
    echo "[[33mB[m]ash on Windows"
    echo "[[33mA[m]rch"
    echo "[[33mE[m]xit"

    echo -n "Choice: "
    read INPUT
    case "$INPUT" in
      [Uu]) SYS_TYPE="Ubuntu";;
      [Ff]) SYS_TYPE="FreeBSD";;
      [Dd]) SYS_TYPE="Darwin";;
      [Nn]) SYS_TYPE="Android";;
      [Bb]) SYS_TYPE="Bash on Windows";;
      [Aa]) SYS_TYPE="Arch";;
      *) exit;;
    esac
esac

########################################
# Check sudo

if [ ! "$SYS_TYPE" = "Android" ]
then
  case `id -u` in
    0) SU_DO="";;
    *)
      if [ ! $(command -v sudo) ]
      then
        checkContinue "sudo not found"
      else
        SU_DO="sudo"
      fi
      ;;
  esac
fi

########################################
# Determine package manager
echo -n "[34mChecking package manager.. [[m"
if [ $(command -v apt-get) ]
then
  echo "[32mapt-get[34m][m"
  if [ ! "$SYS_TYPE" = "Ubuntu" ] \
    && [ ! "$SYS_TYPE" = "Bash on Windows" ] \
    && [ ! "$SYS_TYPE" = "Android" ]
  then
    checkContinue "OS mismatch"
  fi
  PACKAGE_INSTALL="$SU_DO apt-get -y install"

elif [ $(command -v pkg) ]
then
  echo "[32mpkg[34m][m"
  [ ! "$SYS_TYPE" = "FreeBSD" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="$SU_DO pkg install -y"

elif [ $(command -v brew) ]
then
  echo "[32mbrew[34m][m"
  [ ! "$SYS_TYPE" = "Darwin" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="brew install"

elif [ $(command -v pacaur) ]
then
  echo "[32mpacaur[34m][m"
  [ ! "$SYS_TYPE" = "Arch" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="pacaur --noedit --noconfirm -S"

elif [ $(command -v pacman) ]
then
  echo "[32mpacman[34m][m"
  [ ! "$SYS_TYPE" = "Arch" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="$SU_DO pacman --noconfirm -S"

else
  echo "[31mFAIL[34m][m"
  echo "[31mCould not determine package manager[m"
  exit
fi

########################################
# Suggest pacaur
if [[ "$PACKAGE_INSTALL" == "$SU_DO pacman --noconfirm -S" ]] && ! installPacaur
then
  echo "[31mCould not install pacaur![m"
  echo -n "Continue using pacman? [Y/n] "
  read CONTINUE
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
# checkInstall "NeoVim" "$PACKAGE_INSTALL python3-neovim" '[ $(command -v 'nvim') ]'
if [[ "$SYS_TYPE" == "Darwin" ]]
then
  checkInstall "Vim" "$PACKAGE_INSTALL vim --with-lua" '[ $(command -v 'vim') ]'
else
  checkInstall "Vim" "$PACKAGE_INSTALL vim-nox" '[ $(command -v 'vim') ]'
fi

########################################
# Install Vim-Plug
# checkInstall "Vundle" 'git clone https://github.com/VundleVim/Vundle.vim.git "$HOME"/.vim/bundle/Vundle.vim' '[ -d "$HOME"/.vim/bundle/Vundle.vim ]'

# NeoVim
if [ $(command -v nvim) ]
then
  checkInstall "Vim-Plug for NeoVim" 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' '[ -f ~/.local/share/nvim/site/autoload/plug.vim ]'
else
  echo "[33mSkipping Vim-Plug for NeoVim[m"
fi

# Vim
if [ $(command -v vim) ]
then
  checkInstall "Vim-Plug for Vim" 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' '[ -f ~/.vim/autoload/plug.vim ]'
else
  echo "[33mSkipping Vim-Plug for Vim[m"
fi

########################################
# Install tmux
if checkInstallDefault tmux
then
  echo -n "[34mChecking TMUX Powerline.. [[m"
  if [ -f "$HOME"/.tmux-powerlinerc ]
  then
    echo "[32mOK[34m][m"
    FORCE=false
    echo -n "Force generation? [y/N] "
    read INPUT
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
if checkInstallDefault zsh && [ ! "$SYS_TYPE" = "Bash on Windows" ]
then
  echo -n "[34mChecking default shell.. [[m"
  if [[ "$SHELL" == */zsh ]]
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    echo -n "Set ZSH as main shell? [y/N] "
    read INPUT
    case $INPUT in
      [Yy] )
        echo "[34mSetting as main shell..[m"

        if chsh -s $(which zsh)
        then
          echo "[32mDone![m"
          export SHELL=zsh
        else
          checkContinue "Could not set the main shell!"
        fi
        ;;
    esac
  fi
fi

########################################
# Install Oh My ZSH
checkInstall "Oh My ZSH" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"' '[ -d "$HOME"/.oh-my-zsh ]'

########################################
# Install ccat
if [[ "$SYS_TYPE" == "Darwin" ]]
then
  checkInstall "ccat" "$SU_DO easy_install pygments" '[ $(command -v 'pygmentize') ]'
elif [[ "$SYS_TYPE" == "Arch" ]]
then
  checkInstall "ccat" "$PACKAGE_INSTALL pygmentize" '[ $(command -v 'pygmentize') ]'
else
  checkInstall "ccat" "$PACKAGE_INSTALL python-pygments" '[ $(command -v 'pygmentize') ]'
fi

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
    checkContinue "Could not create bin folder!"
  fi
fi

########################################
# Make symlinks
echo "[33mMaking symlinks..[m"
if [ $(command -v zsh) ]
then
  installFile s zsh .aliasrc
  installFile s zsh .zshrc

  if [ -d "$HOME"/.oh-my-zsh ]
  then
    installFile s zsh simpalt.zsh-theme .oh-my-zsh/custom
    installFile s zsh nali .oh-my-zsh/custom/plugins
  else
    echo "[33mSkipping Oh My ZSH links[m"
  fi
else
  echo "[33mSkipping ZSH links[m"
fi

if [ $(command -v nvim) ] || [ $(command -v vim) ]
then
  installFile s vim vim .config/m-lima
else
  echo "[33mSkipping generic Vim links[m"
fi

if [ $(command -v nvim) ]
then
  installFile s vim init.vim .config/nvim
  installFile s vim grayalt.vim .config/nvim/colors
else
  echo "[33mSkipping NeoVim links[m"
fi

if [ $(command -v vim) ]
then
  installFile s vim .vimrc
  installFile s vim grayalt.vim .vim/colors
else
  echo "[33mSkipping Vim links[m"
fi

if [ $(command -v tmux) ]
then
  installFile s scripts tmx bin
  installFile s tmux .tmux.conf
else
  echo "[33mSkipping Tmux links[m"
fi

########################################
# Copy files
echo "[33mCopying files..[m"

if [ $(command -v tmux) ]
then
  if installFile c tmux .tmux.conf.local
  then
    echo "set-option -g default-shell $(which zsh)" >> "$HOME"/.tmux.conf.local
    echo "set-option -g status-left \"#($BASE_DIR/tmux/tmux-powerline/powerline.sh left)\"" >> "$HOME"/.tmux.conf.local
    echo "set-option -g status-right \"#($BASE_DIR/tmux/tmux-powerline/powerline.sh right)\"" >> "$HOME"/.tmux.conf.local
  fi
else
  echo "[33mSkipping Tmux files[m"
fi

if [ $(command -v zsh) ]
then
  if installFile c zsh .zshrc.local
  then
    if [[ "$PACKAGE_INSTALL" == "pacaur --noedit --noconfirm -S" ]]
    then
      echo 'alias pc=pacaur' >> "$HOME"/.zshrc.local
    fi
    vim "$HOME"/.zshrc.local
  fi

  if [ -d "$HOME"/.oh-my-zsh ]
  then
    if installFile c fd config .config/m-lima/fd
    then
      vim "$HOME"/.config/m-lima/fd/config
    fi
  else
    echo "[33mSkipping Oh My ZSH links[m"
  fi
else
  echo "[33mSkipping ZSH files[m"
fi


########################################
# Setup locale
echo "[34mDownloading font..[m"
echo -n "Download DejaVu Sans for Powerline? [y/N] "
read INPUT
case $INPUT in
  [Yy] )
    cd "$HOME"
    curl -s -L 'https://raw.githubusercontent.com/powerline/fonts/master/DejaVuSansMono/DejaVu Sans Mono for Powerline.ttf' -o "$HOME/DejaVu Sans Mono for Powerline.ttf" && echo "[32mFont saved as $HOME/DejaVu Sans Mono for Powerline.ttf[m"
    ;;
esac
