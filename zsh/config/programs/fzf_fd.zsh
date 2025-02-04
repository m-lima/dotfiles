export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'

_fzf_compgen_path() {
  echo "${1}"
  command fd "${1}" --follow --hidden --exclude .git 2> /dev/null
}

_fzf_compgen_dir() {
  echo "${1}"
  command fd "${1}" --type file --follow --hidden --exclude .git 2> /dev/null
}
