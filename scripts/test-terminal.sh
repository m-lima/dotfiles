#!/usr/bin/env bash

printf "Normal\n"
printf "\e[31mRed\e[m\n"

echo
printf "\e[1mBold:\e[m       1\n"
printf "\e[2mDim:\e[m        2\n"
printf "\e[3mItalic:\e[m     3\n"
printf "\e[4mUnderline:\e[m  4\n"
printf "\e[5mSlow blink:\e[m 5\n"
printf "\e[6mFast blink:\e[m 6\n"
printf "\e[7mReverse:\e[m    7\n"
printf "\e[8mConceal:\e[m    8 (Conceal)\n"
printf "\e[9mStriked:\e[m    9\n"
for i in {0..511}; do
  format=''
  flags=''

  (( i & 2#100000000 )) && format+='[1m' && flags+='1' || flags+=' '
  (( i & 2#010000000 )) && format+='[2m' && flags+='2' || flags+=' '
  (( i & 2#001000000 )) && format+='[3m' && flags+='3' || flags+=' '
  (( i & 2#000100000 )) && format+='[4m' && flags+='4' || flags+=' '
  (( i & 2#000010000 )) && format+='[5m' && flags+='5' || flags+=' '
  (( i & 2#000001000 )) && format+='[6m' && flags+='6' || flags+=' '
  (( i & 2#000000100 )) && format+='[7m' && flags+='7' || flags+=' '
  (( i & 2#000000010 )) && format+='[8m' && flags+='8' || flags+=' '
  (( i & 2#000000001 )) && format+='[9m' && flags+='9' || flags+=' '

  (( i % 8 )) || printf '\n'
  printf "${flags} ${format}Test!\e[m "
done
echo

echo
printf '\e[4munderline\e[24m\n'
printf '\e[4:1mthis is also underline\e[24m\n'
printf '\e[21mdouble underline\e[24m\n'
printf '\e[4:2mthis is also double underline\e[24m\n'
printf '\e[4:3mcurly underline\e[24m\n'
printf '\e[58;5;10;4mcolored underline\e[59;24m\n'

echo
echo "256 Color"
for i in {0..15} ; do
  printf "\x1b[48;5;%sm%3d\e[0m" "$i" "$i"
  if (( i == 7 )); then
    printf "\n";
  fi
done
printf "\n";
for i in {16..255} ; do
    printf "\x1b[48;5;%sm %3d\e[0m" "$i" "$i"
    if (( (i-15) % 6 == 0 )); then
        printf "\n";
    fi
done

echo
echo "True Color:"

if [[  ${1} == "square" ]]; then
  term_cols="$(tput cols || echo 80)"
  cols=$((term_cols / 2))
  rows=$(( cols / 2 ))
  awk -v cols="$cols" -v rows="$rows" 'BEGIN{
      s="  ";
      m=cols+rows;
      for (row = 0; row<rows; row++) {
        for (col = 0; col<cols; col++) {
            i = row+col;
            r = 255-(i*255/m);
            g = (i*510/m);
            b = (i*255/m);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,(col+row)%2+1,1);
        }
        printf "\n";
      }
      printf "\n\n";
  }'
else
  awk 'BEGIN{
      s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
      for (colnum = 0; colnum<77; colnum++) {
          r = 255-(colnum*255/76);
          g = (colnum*510/76);
          b = (colnum*255/76);
          if (g>255) g = 510-g;
          printf "\033[48;2;%d;%d;%dm", r,g,b;
          printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
          printf "%s\033[0m", substr(s,colnum+1,1);
      }
      printf "\n";
  }'
fi
