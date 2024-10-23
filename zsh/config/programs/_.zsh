PREV_DIR="${CURR_DIR}"
CURR_DIR="${funcsourcetrace[1]%/*}/"

# Bat
if type bat &> /dev/null; then
  source "${CURR_DIR}/bat.zsh"
elif type batcat &> /dev/null; then
  eval $(sed 's/bat /batcat /g' "${CURR_DIR}/bat.zsh")
fi

# Fzf
if [ -f ~/.fzf.zsh ]; then
  source "${CURR_DIR}/fzf.zsh"
  if type fd &> /dev/null; then
    source "${CURR_DIR}/fzf_fd.zsh"
  elif type fdfind &> /dev/null; then
    eval $(sed 's/fd /fdfind /g' "${CURR_DIR}/fzf_fd.zsh")
    alias fd=fdfind
  fi
fi

# Git
if type git &> /dev/null; then
  source "${CURR_DIR}/git.zsh"
fi

# Ls
source "${CURR_DIR}/ls.zsh"

# Rg
if type rg &> /dev/null; then
  source "${CURR_DIR}/rg.zsh"
fi

# Vim
if type nvim &> /dev/null; then
  source "${CURR_DIR}/nvim.zsh"
elif type vim &> /dev/null; then
  eval $(sed 's/nvim/vim/g' "${CURR_DIR}/nvim.zsh")
else
  eval $(sed 's/nvim/vi/g' "${CURR_DIR}/nvim.zsh")
  unalias vi
fi

# Vim
if type zoxide &> /dev/null; then
  source "${CURR_DIR}/zoxide.zsh"
fi

CURR_DIR="${PREV_DIR}"
