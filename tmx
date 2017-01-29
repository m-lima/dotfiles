#!/usr/bin/env bash
if cat /etc/shells | grep zsh &> /dev/null
then
  shell=zsh
else
  shell=bash
fi

if tmux list-sessions 2> /dev/null | grep main: > /dev/null
then
  if [ $(tmux list-sessions | wc -l) == 1 ]
  then
    while true
    do
      tput -Txterm reset
      echo -e "\e[31mOnly main session exists\e[m"
      echo "What do you whish to do?"
      echo -e "[\e[33mA\e[m]ttach to main"
      echo -e "[\e[33mN\e[m]ame new session"
      echo -e "[\e[33mE\e[m]xit?"
      read -p "Choice: " input
      case $input in
        [Aa]* )
          tmux attach -t main
          tput -Txterm reset
          exit
          ;;
        [Nn]* )
          echo -e "Current sessions:\e[32m"
          tmux list-sessions
          echo -e -n "\e[m"
          read -p "Name of the session: " name
          if tmux new-session -s $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to create\e[m"
          fi
          ;;
        [Ee]* )
          tput -Txterm reset
          exit
          ;;
      esac
    done
  else
    while true
    do
      tput -Txterm reset
      echo -e "\e[31mSeveral sessions found\e[m"
      echo "What do you whish to do?"
      echo -e "[\e[33mC\e[m]onnect to main"
      echo -e "[\e[33mN\e[m]ame new session"
      echo -e "[\e[33mA\e[m]ttach to last"
      echo -e "[\e[33mP\e[m]ick session"
      echo -e "[\e[33mL\e[m]og normally"
      echo -e "[\e[33mE\e[m]xit?"
      read -p "Choice: " input

      case $input in
        [Cc]* )
          tmux attach -t main
          tput -Txterm reset
          exit
          ;;
        [Nn]* )
          echo -e "Current sessions:\e[32m"
          tmux list-sessions
          echo -e -n "\e[m"
          read -p "Name of the session: " name
          if tmux new-session -s $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to create\e[m"
          fi
          ;;
        [Aa]* )
          # First line
          name=$(tmux list-sessions | head -1 | cut -f1 -d ":")
          # Last line
          #name=$(tmux list-sessions | sed -e '$!d' | cut -f1 -d ":")
          if tmux attach -t $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to attach\e[m"
          fi
          ;;
        [Pp]* )
          echo -e "Current sessions:\e[32m"
          tmux list-sessions
          echo -e -n "\e[m"
          read -p "Name of the session: " name
          if tmux attach -t $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to attach\e[m"
          fi
          ;;
        [Ll]* )
          $($shell)
          exit
          ;;
        [Ee]* )
          tput -Txterm reset
          exit
          ;;
      esac
    done
  fi	
else
  if tmux list-sessions &> /dev/null
  then
    while true
    do
      tput -Txterm reset
      echo -e "\e[31mMain session not found\e[m"
      echo "What do you whish to do?"
      echo -e "[\e[33mC\e[m]reate main"
      echo -e "[\e[33mN\e[m]ame new session"
      echo -e "[\e[33mA\e[m]ttach to last"
      echo -e "[\e[33mP\e[m]ick session"
      echo -e "[\e[33mL\e[m]og normally"
      echo -e "[\e[33mE\e[m]xit?"
      read -p "Choice: " input

      case $input in
        [Cc]* )
          tmux new-session -s main
          tput -Txterm reset
          exit
          ;;
        [Nn]* )
          echo -e "Current sessions:\e[32m"
          tmux list-sessions
          echo -e -n "\e[m"
          read -p "Name of the session: " name
          if tmux new-session -s $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to create\e[m"
          fi
          ;;
        [Aa]* )
          # First line
          name=$(tmux list-sessions | head -1 | cut -f1 -d ":")
          # Last line
          #name=$(tmux list-sessions | sed -e '$!d' | cut -f1 -d ":")
          if tmux attach -t $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to attach\e[m"
          fi
          ;;
        [Pp]* )
          echo -e "Current sessions:\e[32m"
          tmux list-sessions
          echo -e -n "\e[m"
          read -p "Name of the session: " name
          if tmux attach -t $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to attach\e[m"
          fi
          ;;
        [Ll]* )
          /usr/bin/env $shell
          exit
          ;;
        [Ee]* )
          tput -Txterm reset
          exit
          ;;
      esac
    done
  else
    while true
    do
      tput -Txterm reset
      echo -e "\e[31mNo sessions found\e[m"
      echo "What do you whish to do?"
      echo -e "[\e[33mC\e[m]reate main"
      echo -e "[\e[33mN\e[m]ame new session"
      echo -e "[\e[33mL\e[m]og normally"
      echo -e "[\e[33mE\e[m]xit?"
      read -p "Choice: " input

      case $input in
        [Cc]* )
          tmux new-session -s main
          tput -Txterm reset
          exit
          ;;
        [Nn]* )
          read -p "Name of the session: " name
          if tmux new-session -s $name
          then
            tput -Txterm reset
            exit
          else
            echo -e "\e[31mUnable to create\e[m"
          fi
          ;;
        [Ll]* )
          /usr/bin/env $shell
          tput -Txterm reset
          exit
          ;;
        [Ee]* )
          tput -Txterm reset
          exit
          ;;
      esac
    done
  fi
fi
