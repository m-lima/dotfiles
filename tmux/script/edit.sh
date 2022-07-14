#!/usr/bin/env zsh

if [ ${1} ]
then
  word="${1}"
else
  word=`tmux display -p "#{copy_cursor_word}"`
fi
word=(${(s|:|)word})

file="${word[1]}"
if [[ "${word[2]}" =~ '^[0-9]+$' ]]
then
  line="+${word[2]}"
  if [[ "${word[3]}" =~ '^[0-9]+$' ]]
  then
    col="${word[3]}|"
  fi
fi

if [[ "${file[1]}" != "/" ]]
then
  file="`tmux display -p "#{pane_current_path}"`/${file}"
fi

[ -f "${file}" ] || return 0

target=''
session=`tmux display -p "#{session_name}"`
if [[ "${session}" == scratch-* ]]
then
  target=(-t @${session#*@})
fi

pane_id=''
pane_score=''
for pane in `tmux list-panes ${target} -F "#{pane_id}"`
do
  pane_command=`tmux display -t "${pane}" -p "#{pane_current_command}"`
  if [[ "${pane_command}" == "nvim" ]]
  then
    if [ `tmux display -t "${pane}" -p "#{pane_active}"` -eq 1 ]
    then
      pane_id="${pane}"
      break
    elif [ `tmux display -t "${pane}" -p "#{pane_last}"` -eq 1 ]
    then
      pane_id="${pane}"
      pane_score=5
    elif (( pane_score < 4 ))
    then
      pane_id="${pane}"
      pane_score=4
    fi
  elif (( pane_score < 4 )) && [[ "${pane_command}" == "vim" ]]
  then
    if [ `tmux display -t "${pane}" -p "#{pane_active}"` -eq 1 ] && (( pane_score < 3 ))
    then
      pane_id="${pane}"
      pane_score=3
    elif [ `tmux display -t "${pane}" -p "#{pane_last}"` -eq 1 ] && (( pane_score < 2 ))
    then
      pane_id="${pane}"
      pane_score=2
    elif (( ! pane_score ))
    then
      pane_id="${pane}"
      pane_score=1
    fi
  fi
done

# Escape scratch session
[ "${target}" ] && tmux detach && tmux select-window "${target[2]}"

if [ "${pane_id}" ]
then
  # Escape tmux mode
  [ `tmux display -t "${pane_id}" -p "#{pane_in_mode}"` -eq 1 ] && tmux send-keys -t "${pane_id}" 'C-c'

  # Escape from the terminal
  tmux send-keys -t "${pane_id}" -H 1c

  # Open file
  tmux send-keys -t "${pane_id}" Escape '\;e '"${line}"' '"${file}" Enter

  # Shift cursor
  [ ${col} ] && tmux send-keys -t "${pane_id}" "${col}"

  # Switch focus
  tmux select-pane -t "${pane_id}"
else
  editor=`command -v nvim 2> /dev/null`
  if [ $? -eq 0 ]
  then
    tmux split-window -h ${target} "${editor} ${line} ${file}"
  else
    tmux split-window -h ${target} "vi ${line} ${file}"
  fi
  [ ${col} ] && tmux send-keys ${target} "${col}" || true
fi
