" Base config
source ~/.config/m-lima/vim/base/init.vim

" Neovim specific
if has('nvim')
  source ~/.config/m-lima/vim/nvim/init.vim
  source ~/.config/m-lima/vim/nvim/plugins/init.vim
endif

" Functions
source ~/.config/m-lima/vim/functions.vim
