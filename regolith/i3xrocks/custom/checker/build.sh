#!/usr/bin/env bash
gcc -O3 gpu-usage.c -o gpu-usage -flto -lX11 \
  && strip gpu-usage \
  && sudo chown root:root gpu-usage \
  && sudo chmod 755 gpu-usage \
  && sudo chmod u+s gpu-usage

if [ $? -eq 0 ] && [[ "$1" == "install" ]]
then
  sudo rm /usr/share/i3xrocks/gpu-usage
  sudo ln -s "${PWD}/gpu-usage" /usr/share/i3xrocks/.
fi
