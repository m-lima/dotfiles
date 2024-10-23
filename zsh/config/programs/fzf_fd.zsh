export FZF_DEFAULT_COMMAND='fdfind --type file --follow --hidden --exclude .git'

_fzf_compgen_path() {
  echo "${1}"
  command fdfind "${1}" --follow --hidden --exclude .git 2> /dev/null
}

_fzf_compgen_dir() {
  echo "${1}"
  command fdfind "${1}" --type file --follow --hidden --exclude .git 2> /dev/null
}
