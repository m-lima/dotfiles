PREV_DIR="${CURR_DIR}"
CURR_DIR="${funcsourcetrace[1]%/*}/"

# Bat
if type batcat &> /dev/null; then
  alias bat=batcat
fi
if type bat &> /dev/null; then
  source "${CURR_DIR}/bat.zsh"
fi

# Fzf
if [ -f ~/.fzf.zsh ]; then
  echo source "${CURR_DIR}/fzf.zsh"
  if type fdfind &> /dev/null; then
    alias fd=fdfind
  fi
  if type fd &> /dev/null; then
    source "${CURR_DIR}/fzf_fd.zsh"
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
  source "${CURR_DIR}/vim.zsh"
fi

# Vim
if type zoxide &> /dev/null; then
  source "${CURR_DIR}/zoxide.zsh"
fi

CURR_DIR="${PREV_DIR}"
