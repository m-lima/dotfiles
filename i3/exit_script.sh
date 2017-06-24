#!/bin/bash

while [ "$select" != "NO" -a "$select" != "YES" ]
do
  select=$(echo -e 'YES\nNO' | rofi -lines 2 -dmenu -p "Do you really want to exit i3? This will end your X session.")
  [ -z "$select" ] && exit 0
done

[ "$select" = "NO" ] && exit 0

i3-msg exit
