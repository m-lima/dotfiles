#!/usr/bin/env zsh

if [[ "$1" == "ram" ]]
then

  memory=( `free -m | awk 'FNR == 2 {print $3*100; print $2}'` )

  if (( memory[1] > 99900 ))
  then
    used=$(( (memory[1] / 1024 + 5) / 10 ))
    echo -n $(( used / 10 ))"."$(( used % 10 ))G
  else
    used=$(( (memory[1] + 5) / 10 ))
    echo -n $(( used / 10 ))M
  fi

  percentage=$(( memory[1] * 10 / memory[2] ))
  echo " ("$(( (percentage + 5) / 10 ))"%)"

elif [[ "$1" == "cpu" ]]
then

  initial=( `grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$7+$8; print $2+$3+$4+$5+$6+$7+$8}'` )
  sleep 4
  final=( `grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$7+$8; print $2+$3+$4+$5+$6+$7+$8}'` )

  load=$(( (final[1] - initial[1]) * 1000 / (final[2] - initial[2]) ))
  echo $(( load / 10 ))"."$(( load % 10 ))"%"

fi
