#!/usr/bin/env zsh

IFS='
'

volumes=( `amixer get Master | grep -o "\[.*%\]" | grep -o "[0-9]*"` )
count=$#volumes
volume=0

for channel in $volumes
do
  volume=$(( volume + channel ))
done

volume=$(( volume / count ))

statuses=( `amixer get Master | grep -o "\[\(on\|off\)\]"` )
muted=true

for channel in $statuses
do
  if [[ "$channel" == "[on]" ]]
  then
    muted=false
    break
  fi
done

if [[ "$muted" == "true" ]]
then
  echo -n "    "
else
  if (( volume < 50 ))
  then
    echo -n "    "
  else
    echo -n "    "
  fi
fi
echo "$volume%"

#"${BLOCK_BUTTON}"
#1: left
#2: middle
#3: right
#4: wheel up
#5: wheel down
