alias rg='rg --smart-case'

function rgc {
  if [ -n "${1}" ]; then
    comment="${1}"
  else
    comment='//'
  fi

  rg -U "(^[\\t ]*${comment}[^\\n]*\\n){2,}"
}
