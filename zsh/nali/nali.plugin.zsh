function bd {
  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    cd -$1 > /dev/null
  else
    cd - > /dev/null
  fi

}

function vd {
  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    local it=$1
  else
    local it=1
  fi

  until [ $it -eq 0 ]
  do
    local BACK=../$BACK
    (( it-- ))
  done

  cd $BACK
}

function fd {
  if [ "$1" ]
  then

    if [ ! -f ~/.config/m-lima/fd/config ]
    then
      echo Entry file not found at "$HOME/.config/m-lima/fd/config"
      return -1
    fi

    while read line
    do
      entry=$(echo $line | cut -d : -f 1)
      case $entry in
        $1)
          dir=$(echo $line | cut -d : -f 2)
          eval cd $dir/$2
          return
          ;;
      esac
    done < ~/.config/m-lima/fd/config
    echo Entry not found
    return -1

  else
    cd ~
  fi
}
