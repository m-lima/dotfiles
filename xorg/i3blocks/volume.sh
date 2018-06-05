#!/usr/bin/env zsh

## Start with user input
case ${BLOCK_BUTTON} in
  1) amixer -q set Master toggle ;;
  4) amixer -q set PCM 1.5dB+ ;;
  5) amixer -q set PCM 1.5dB- ;;
esac

IFS='
'


### Get the volumes
volumes=( `amixer get PCM | grep -o "\[.*%\]" | grep -o "[0-9]*"` )
count=$#volumes
volume=0

for channel in $volumes
do
  volume=$(( volume + channel ))
done

volume=$(( volume / count ))


### Get if muted/unmuted
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


### Make sure all controls are in sync
if [[ "${BLOCK_BUTTON}" == "1" ]] && [[ "$muted" == "false" ]]
then
  amixer -q set PCM unmute
  amixer -q set Surround unmute
  amixer -q set Center unmute
  amixer -q set LFE unmute
fi


### Time to print
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
