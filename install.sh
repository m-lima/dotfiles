#!/bin/bash

################################################################################
# Functions                                                                    #
################################################################################

################################################################################
# Gets the full path to a relative path
#
# arg1: The path to be converted into absolute
# return: The full path

function fullPath {
  local targetFile physDir result

  targetFile="${1}"

  cd `dirname "${targetFile}"`
  targetFile=`basename "${targetFile}"`

  # Compute the canonicalized name by finding the physical path
  # for the directory we're in and appending the target file.
  physDir=`pwd -P`
  result="${physDir}/${targetFile}"
  result="${result%/.}"
  echo ${result}
}

################################################################################
# Shows a prompt to confirm continuation. Aborts the script if cancelled
#
# return: Success if accepted. Will abort if cancelled

function checkContinue {
  local input

  if [ "${1}" ]
  then
    echo "[31m${1}[m"
  fi

  echo -n "Continue? [y/N] "
  read input
  case ${input} in
    [Yy] ) return 0 ;;
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
  local input

  echo -n "[34mChecking ${1}.. [[m"
  if eval ${3}
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    echo -n "Install ${1}? [Y/n] "
    read input
    case ${input} in
      [Nn] ) ;;
      *)
        if eval "${2}"
        then
          echo "[32mDone![m"
        else
          checkContinue "Could not install ${1}!"
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
  local checkString='[ $(command -v '"${1}"') ]'
  checkInstall ${1} "${PACKAGE_INSTALL} ${1}" "${checkString}"
}

################################################################################
# Installs a file. The installation might be a copy or a symlink
# The target file is checked for existence and a prompt will ask if it should
# be overwritten
#
# arg1: Either "s" or "c" for symlink or copy, respectively
# arg2: The source path
# [arg3]: Installation path. Defaults to $HOME.
# [arg4]: Installation file name override.
# return: Failure if cancelled, or status code of install operation

function installFile {
  local installPath installName overwrite input
  local source="${BASE_DIR}/${2}"

  if [ ! -f "${source}" ] && [ ! -d "${source}" ]
  then
    echo "[31mSource path does not exist:[m ${source}"
    return 1
  fi

  if [ "${3}" ]
  then
    if [ "${3:0:1}" = "/" ]
    then
      installPath="${3}/"
    else
      installPath="${HOME}/${3}/"
    fi
  else
    installPath="${HOME}/"
  fi

  if [ "${4}" ]
  then
    installName="${4}"
  else
    installName=`basename "${2}"`
  fi

  echo "[34mInstalling ${installPath}${installName}..[m"

  overwrite=false

  if [ ! -d ${installPath} ]
  then
    echo -n "${installPath} does not exist. Create? [Y/n] "
    read input
    case ${input} in
      [Nn] )
        checkContinue
        return 1
        ;;
      * ) mkdir -p "${installPath}" ;;
    esac
  fi

  if [ -f "${installPath}${installName}" ] || [ -d "${installPath}${installName}" ] || [ -L "${installPath}${installName}" ]
  then
    if [ ${NO_OVERWRITE} ]
    then
      echo "Already exists. Skipping.."
      return 1
    else
      echo -n "${installPath}${installName} already exists. Overwrite? [y/N] "
      read input
      case ${input} in
        [Yy] )
          rm "${installPath}${installName}"
          overwrite=true
          ;;
      esac
    fi
  else
    overwrite=true
  fi

  if [[ "${overwrite}" == "true" ]]
  then
    if [[ "${1}" == "s" ]]
    then
      ln -sf "${source}" "${installPath}${installName}"
    elif [[ "${1}" == "c" ]]
    then
      cp -r "${source}" "${installPath}${installName}"
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
  local input

  echo -n "Install pacaur? [Y/n] "
  read input
  case ${input} in
    [Nn] )
      return 0
      ;;
  esac

  if ! checkInstallDefault git
  then
    return 1
  fi
  GIT_INSTALLED=1

  ${SU_DO} pacman -S base-devel fakeroot jshon expac yajl

  rm -rf /tmp/dotfile_pacaur_install 2> /dev/null
  mkdir /tmp/dotfile_pacaur_install

  cd /tmp/dotfile_pacaur_install
  if git clone https://aur.archlinux.org/cower.git
  then
    cd cower
    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
    makepkg && ${SU_DO} pacman --noconfirm -U *.tar.xz
  fi

  cd /tmp/dotfile_pacaur_install
  if ! git clone https://aur.archlinux.org/pacaur.git
  then
    return 1
  fi

  cd pacaur
  if makepkg && ${SU_DO} pacman --noconfirm -U *.tar.xz
  then
    echo "[34mUsing pacaur[m"
    PACKAGE_INSTALL="pacaur --noedit --noconfirm -S"
    return 0
  else
    return 1
  fi
}

function delete {
  local input searchFlag deleteFlag

  if [[ "${1}" == "file" ]]
  then
    searchFlag='-f'
  elif [[ "${1}" == "dir" ]]
  then
    searchFlag='-d'
    deleteFlag='-rf'
  else
  fi

  shift

  if [ ${searchFlag} "${1}" ]
  then
    echo -n "Delete ${1}? [y/N] "
    read input
    case ${input} in
      [Yy] )
        rm ${deleteFlag} "${1}"
        ;;
    esac
  fi
}

################################################################################
# Script start                                                                 #
################################################################################

########################################
# Variables
BASE_DIR=$(dirname $(fullPath ${0}))
SU_DO=""
SYS_TYPE=""
PACKAGE_INSTALL=""
PLUGIN_MANAGER=""
ZSH_FRAMEWORK=""

if [[ "${1}" = "-no" ]]
then
  NO_OVERWRITE=1
fi

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

if [ -z "${SYS_TYPE}" ]
then
  echo "[31mFAIL[34m][m"
  change=Y
else
  echo "[32m${SYS_TYPE}[34m][m"
  if [ -z ${NO_OVERWRITE} ]
  then
    echo -n "Choose a different OS? [y/N] "
    read change
  fi
fi

case ${change} in
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
    read input
    case "${input}" in
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

if [ ! "${SYS_TYPE}" = "Android" ]
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
  if [ ! "${SYS_TYPE}" = "Ubuntu" ] \
    && [ ! "${SYS_TYPE}" = "Bash on Windows" ] \
    && [ ! "${SYS_TYPE}" = "Android" ]
  then
    checkContinue "OS mismatch"
  fi
  PACKAGE_INSTALL="${SU_DO} apt-get -y install"

elif [ $(command -v pkg) ]
then
  echo "[32mpkg[34m][m"
  [ ! "${SYS_TYPE}" = "FreeBSD" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="${SU_DO} pkg install -y"

elif [ $(command -v brew) ]
then
  echo "[32mbrew[34m][m"
  [ ! "${SYS_TYPE}" = "Darwin" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="brew install"

elif [ $(command -v pacaur) ]
then
  echo "[32mpacaur[34m][m"
  [ ! "${SYS_TYPE}" = "Arch" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="pacaur --noedit --noconfirm -S"

elif [ $(command -v pacman) ]
then
  echo "[32mpacman[34m][m"
  [ ! "${SYS_TYPE}" = "Arch" ] && checkContinue "OS mismatch"
  PACKAGE_INSTALL="${SU_DO} pacman --noconfirm -S"

else
  echo "[31mFAIL[34m][m"
  echo "[31mCould not determine package manager[m"
  exit
fi

########################################
# Suggest pacaur
if [[ "${PACKAGE_INSTALL}" == "${SU_DO} pacman --noconfirm -S" ]] && ! installPacaur
then
  echo "[31mCould not install pacaur![m"
  echo -n "Continue using pacman? [Y/n] "
  read input
  case ${input} in
    [Nn] )
      exit
      ;;
  esac
fi

cd ${HOME}

########################################
# Install git
[ -z ${GIT_INSTALLED} ] && checkInstallDefault git

########################################
# Install curl
checkInstallDefault curl

########################################
# Install NeoVim
checkInstall "NeoVim" "${PACKAGE_INSTALL} neovim" '[ $(command -v 'nvim') ]'

########################################
# Check pluginManager
echo -n "[34mChecking Plugin Manager.. [[m"
if [ -f "${HOME}/.config/m-lima/zsh/local.zsh" ]
then
  PLUGIN_MANAGER=`awk '{ if ($1 ~ /^pluginManager=.+/) { print $1 }}' "${HOME}/.config/m-lima/zsh/local.zsh" | cut -d '=' -f2 | tail -1`

  if [ -z "${PLUGIN_MANAGER}" ]
  then
    echo "[31mFAIL[34m][m"
    change=Y
  else
    echo "[32m${PLUGIN_MANAGER}[34m][m"
    if [ -z ${NO_OVERWRITE} ]
    then
      echo -n "Choose a different manager? [y/N] "
      oldPluginManager="${PLUGIN_MANAGER}"
      read change
    fi
  fi

  case ${change} in
    [Yy] )
      echo "[33mSelect your manager[m"
      echo "Z[[33mG[m]en"
      echo "Z[[33mP[m]lug"
      echo "[[33mN[m]one"
      echo "[[33mE[m]xit"

      echo -n "Choice: "
      read input
      case "${input}" in
        [Gg]) PLUGIN_MANAGER="zgen";;
        [Pp]) PLUGIN_MANAGER="zplug";;
        [Nn]) PLUGIN_MANAGER="";;
        *) exit;;
      esac

      echo -n "Updating local configuration"
      if sed -i 's~pluginManager=.*~pluginManager='"${PLUGIN_MANAGER}"'~g' "${HOME}/.config/m-lima/zsh/local.zsh"
      then
        echo " by replacing existing declaration"
      else
        echo " by inserting new declaration"
        echo 'pluginManager='"${PLUGIN_MANAGER}" >> "${HOME}/.config/m-lima/zsh/local.zsh"
      fi
  esac
fi

########################################
# Check ZSH framework
echo -n "[34mChecking ZSH framework.. [[m"
if [ -f "${HOME}/.config/m-lima/zsh/local.zsh" ]
then
  ZSH_FRAMEWORK=`awk '{ if ($1 ~ /^zshFramework=.+/) { print $1 }}' "${HOME}/.config/m-lima/zsh/local.zsh" | cut -d '=' -f2 | tail -1`

  if [ -z "${ZSH_FRAMEWORK}" ]
  then
    echo "[31mFAIL[34m][m"
    change=Y
  else
    oldZshFramework="${ZSH_FRAMEWORK}"
    echo "[32m${ZSH_FRAMEWORK}[34m][m"
    if [ -z ${NO_OVERWRITE} ]
    then
      echo -n "Choose a different framework? [y/N] "
      read change
    fi
  fi

  case ${change} in
    [Yy] )
      echo "[33mSelect your framework[m"
      echo "[[33mP[m]rezto"
      echo "[[33mO[m]h-my-zsh"
      echo "[[33mN[m]one"
      echo "[[33mE[m]xit"

      echo -n "Choice: "
      read input
      case "${input}" in
        [Pp]) ZSH_FRAMEWORK="prezto";;
        [Oo]) ZSH_FRAMEWORK="omz";;
        [Nn]) ZSH_FRAMEWORK="";;
        *) exit;;
      esac

      echo -n "Updating local configuration"
      if sed -i 's~zshFramework=.*~zshFramework='"${ZSH_FRAMEWORK}"'~g' "${HOME}/.config/m-lima/zsh/local.zsh"
      then
        echo " by replacing existing declaration"
      else
        echo " by inserting new declaration"
        echo 'zshFramework='"${ZSH_FRAMEWORK}" >> "${HOME}/.config/m-lima/zsh/local.zsh"
      fi
  esac
fi

########################################
# Install vim
if [[ "${SYS_TYPE}" == "Darwin" ]]
then
  checkInstall "Vim" "${PACKAGE_INSTALL} vim --with-lua" '[ $(command -v 'vim') ]'
elif [[ "${SYS_TYPE}" == "Arch" ]]
then
  checkInstall "Vim" "${PACKAGE_INSTALL} vim" '[ $(command -v 'vim') ]'
else
  checkInstall "Vim" "${PACKAGE_INSTALL} vim-nox" '[ $(command -v 'vim') ]'
fi

########################################
# Install Vim-Plug
# checkInstall "Vundle" 'git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}"/.vim/bundle/Vundle.vim' '[ -d "${HOME}"/.vim/bundle/Vundle.vim ]'

# NeoVim
if [ $(command -v nvim) ]
then
  if checkInstall "Vim-Plug for NeoVim" 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' '[ -f ~/.local/share/nvim/site/autoload/plug.vim ]'
  then
    nvim -c 'PlugInstall' -c 'qa!'
  fi
else
  echo "[33mSkipping Vim-Plug for NeoVim[m"
fi

# Vim
if [ $(command -v vim) ]
then
  if checkInstall "Vim-Plug for Vim" 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' '[ -f ~/.vim/autoload/plug.vim ]'
  then
    vim -c 'PlugInstall' -c 'qa!'
  fi
else
  echo "[33mSkipping Vim-Plug for Vim[m"
fi

########################################
# Install tmux
checkInstallDefault

########################################
# Install ZSH
if checkInstallDefault zsh && [ ! "${SYS_TYPE}" = "Bash on Windows" ]
then
  echo -n "[34mChecking default shell.. [[m"
  if [[ "${SHELL}" == */zsh ]]
  then
    echo "[32mOK[34m][m"
  else
    echo "[31mFAIL[34m][m"

    echo -n "Set ZSH as main shell? [y/N] "
    read input
    case ${input} in
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
# Install bat
checkInstall "Bat" "${PACKAGE_INSTALL} bat" '[ $(command -v "bat") ] || [ $(command -v "batcat") ]'

########################################
# Install delta
[ "${SYS_TYPE}" = "Ubuntu" ] || checkInstall "Delta" "${PACKAGE_INSTALL} git-delta" '[ $(command -v "delta") ]'

########################################
# Install fzf
checkInstall "fzf" 'git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/code/others/fzf && "${HOME}/code/others/fzf/install" --no-fish' '[ $(command -v "fzf") ]'

########################################
# Create ~/bin
echo -n "[34mChecking bin folder.. [[m"
if [ -d "${HOME}"/bin ]
then
  echo "[32mOK[34m][m"
else
  echo "[31mFAIL[34m][m"
  echo "[34mCreating folder..[m"

  if mkdir "${HOME}"/bin &> /dev/null
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
  installFile s zsh/.zshrc
  installFile s zsh/config .config/m-lima zsh
else
  echo "[33mSkipping ZSH links[m"
fi

if [ $(command -v nvim) ] || [ $(command -v vim) ]
then
  installFile s vim/config .config/m-lima vim
else
  echo "[33mSkipping generic Vim links[m"
fi

if [ $(command -v nvim) ]
then
  installFile s vim/init.vim .config/nvim
  installFile s vim/grayalt.vim .config/nvim/colors
  installFile s vim/simpalt.vim .config/nvim/colors
  installFile s vim/config/lua .config/nvim
else
  echo "[33mSkipping NeoVim links[m"
fi

if [ $(command -v vim) ]
then
  installFile s vim/init.vim . .vimrc
  installFile s vim/grayalt.vim .vim/colors
  installFile s vim/simpalt.vim .vim/colors
else
  echo "[33mSkipping Vim links[m"
fi

if [ $(command -v nvim) ] || [ $(command -v vim) ]
then
  installFile s vim/.ideavimrc .
else
  echo "[33mSkipping IdeaVim links[m"
fi

if [ $(command -v tmux) ]
then
  if installFile s tmux .config/m-lima tmux
  then
    ln -sf "${HOME}/.config/m-lima/tmux/tmux.conf" "${HOME}/.tmux.conf"
    touch "${HOME}/.config/m-lima/tmux/local.conf"
    vi "${HOME}/.config/m-lima/tmux/local.conf"
  fi
else
  echo "[33mSkipping Tmux links[m"
fi

if [ $(command -v alacritty) ]
then
  installFile s gui/alacritty/alacritty.yml .config/alacritty
  case "${SYS_TYPE}" in
    Darwin)
      installFile s gui/alacritty/alacritty.macos.yml .config/m-lima/alacritty alacritty.yml ;;
    *)
      installFile s gui/alacritty/alacritty.linux.yml .config/m-lima/alacritty alacritty.yml ;;
  esac
fi

installFile s scripts/scaffpp bin
installFile s scripts/scaffjs bin

if [[ "${SYS_TYPE}" == "Android" ]]
then
  installFile s termux/colors.properties .termux
fi

if [ $(command -v bat) ]
then
  installFile s config/bat/config `bat --config-dir`
elif [ $(command -v batcat) ]
then
  installFile s config/bat/config `batcat --config-dir`
fi

if [ $(command -v delta) ]
then
  installFile s config/delta .config/m-lima
fi

########################################
# Copy files
echo "[33mCopying files..[m"

if [ $(command -v zsh) ]
then
  if installFile c zsh/local.zsh .config/m-lima/zsh
  then
    if [[ "${PACKAGE_INSTALL}" == "pacaur --noedit --noconfirm -S" ]]
    then
      echo "alias pc='pacaur --color always'" >> "${HOME}/.config/m-lima/zsh/local.zsh"
      echo "alias pcm='pacman --color always'" >> "${HOME}/.config/m-lima/zsh/local.zsh"
    fi
    [ "${PLUGIN_MANAGER}" ] && echo "pluginManager=${PLUGIN_MANAGER}" >> "${HOME}/.config/m-lima/zsh/local.zsh"
    [ "${ZSH_FRAMEWORK}" ] && echo "zshFramework=${ZSH_FRAMEWORK}" >> "${HOME}/.config/m-lima/zsh/local.zsh"
    vi "${HOME}/.config/m-lima/zsh/local.zsh"
  fi

  if installFile c zsh/final.zsh .config/m-lima/zsh
  then
    vi "${HOME}/.config/m-lima/zsh/final.zsh"
  fi

  if installFile c config/fd/config .config/m-lima/fd
  then
    vi "${HOME}/.config/m-lima/fd/config"
  fi
else
  echo "[33mSkipping ZSH files[m"
fi

########################################
# PyEnv for (Neo)Vim
if [ $(command -v nvim) ]
then
  if [ ! -d "${HOME}/code/python/env/vim" ] || [ -z ${NO_OVERWRITE} ]
  then
    echo "[34mInstalling vim pyenv..[m"
    echo -n "Create pyenv for vim? [y/N] "
    read input
    case ${input} in
      [Yy] )
        python3 -m venv "${HOME}/code/python/env/vim"
        source "${HOME}/code/python/env/vim/bin/activate"
        pip3 install pynvim
        deactivate
    esac
  fi
fi

########################################
# Clean deprecated files

delete file "${HOME}/.tmux.conf.local"
delete file "${HOME}/.tmux-powerlinerc"
delete dir "${HOME}/.config/coc"
delete file "${HOME}/.config/nvim/coc-settings.json"

########################################
# Download fonts
echo "[33mDownloading fonts..[m"

if [ ! -f "${HOME}/DejaVu Sans Mono for Powerline.ttf" ] || [ -z ${NO_OVERWRITE} ]
then
  echo "[34mDownloading font..[m"
  echo -n "Download DejaVu Sans for Powerline? [y/N] "
  read input
  case ${input} in
    [Yy] )
      cd "${HOME}"
      curl -s -L 'https://raw.githubusercontent.com/powerline/fonts/master/DejaVuSansMono/DejaVu Sans Mono for Powerline.ttf' -o "${HOME}/DejaVu Sans Mono for Powerline.ttf" && echo "[32mFont saved as ${HOME}/DejaVu Sans Mono for Powerline.ttf[m"
      ;;
  esac
fi

if [ ! -f "${HOME}/DejaVu Sans Mono Nerd Font.zip" ] || [ -z ${NO_OVERWRITE} ]
then
  echo -n "Download DejaVu Sans Nerd Font? [y/N] "
  read input
  case ${input} in
    [Yy] )
      cd "${HOME}"
      curl -s -L 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/DejaVuSansMono.zip' -o "${HOME}/DejaVu Sans Mono Nerd Font.zip" && echo "[32mFont saved as ${HOME}/DejaVu Sans Mono Nerd Font.zip[m"
      ;;
  esac
fi
