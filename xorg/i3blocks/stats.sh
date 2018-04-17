#!/usr/bin/env zsh

if [[ "$1" == "ram" ]]
then
  total=`cat /proc/meminfo | grep MemTotal | grep -o "[0-9]*"`
  free=`cat /proc/meminfo | grep MemFree | grep -o "[0-9]*"`

  used=$(( (total - free) * 1000 ))
  echo -n $(( used / 1024 / 1024 ))"MiB"

  used=$(( used / total ))
  echo " ("$(( used / 10 ))"."$(( used % 10 ))"%)"

elif [[ "$1" == "cpu" ]]
then

  initial=( `grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$7+$8; print $2+$3+$4+$5+$6+$7+$8}'` )
  sleep 4
  final=( `grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$7+$8; print $2+$3+$4+$5+$6+$7+$8}'` )

  load=$(( (final[1] - initial[1]) * 1000 / (final[2] - initial[2]) ))
  echo $(( load / 10 ))"."$(( load % 10 ))"%"
fi
