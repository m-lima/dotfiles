if [[ "$1" == "ram" ]]
then
  total=`cat /proc/meminfo | grep MemTotal | grep -o "[0-9]*"`
  free=`cat /proc/meminfo | grep MemFree | grep -o "[0-9]*"`
  used=$(( (total - free) * 1000 ))
  echo -n $(( used / 1024 / 1024 ))"MiB"
  used=$(( used / total ))
  echo " ("$(( used / 10 ))"."$(( used % 10 ))"%)"
fi
