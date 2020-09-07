#!/bin/bash
gcc -O3 gpu-usage.c -o gpu-usage -flto -lX11 \
  && strip gpu-usage \
  && sudo chown root:root gpu-usage \
  && sudo chmod 755 gpu-usage \
  && sudo chmod u+s gpu-usage
