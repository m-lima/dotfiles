#!/bin/bash

## ZSH
echo -n -e "\e[34mChecking ZSH.. [\e[m"
if [ $(which zsh ?> /dev/null) ]
then
  echo -e "OK\e[34m]\e[m"
else
  echo -e "\e[31mFAIL\e[34m]\e[m"
  echo -e "\e[34mInstalling ZSH..\e[m"
  sudo apt-get install zsh

  if [ $? ]
  then
    echo -e "\e[31mCould not install ZSH!\e[m"
    exit
  fi
  echo -e "\e[32mDone!\e[m"

  echo -e "\e[34mSetting as main shell..\e[m"
  chsh -s $(which zsh)

  if [ $? ]
  then
    echo -e "\e[31mCould not the main shell!\e[m"
    exit
  fi
  echo -e "\e[32mDone!\e[m"
fi

## Oh My ZSH
echo -e "\e[34mInstalling Oh My ZSH..\e[m"
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
echo -e "\e[32mDone!\e[m"

## Downloading dotfiles
echo -e "\e[34mSetando the colors and the plugins..\e[m"
sed -i 's~ZSH_THEME="robbyrussell"~ZSH_THEME="simpalt"~' ~/.zshrc
echo "alias bd='cd -'" >> ~/.zshrc
echo "alias vd='cd ..'" >> ~/.zshrc

echo -e "\e[32mDone!\e[m"
echo -e "\e[32mAgora sai desse terminal, que da proxima vez que vc abrir o terminal, o ZSH vai aparecer\e[m"
