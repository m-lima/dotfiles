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
