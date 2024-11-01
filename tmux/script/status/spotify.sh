playing=$("${1}/status/spotify.script")
if [ "${playing}" ]
then
  echo -n "#[fg=colour234]#[fg=colour37,bg=colour234] ${playing} "
fi
