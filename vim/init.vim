" Base config
source ~/.config/m-lima/vim/base.vim

" Coloring
source ~/.config/m-lima/vim/coloring.vim

" Plugins
if has('nvim-0.7')
  source ~/.config/m-lima/vim/plugins_nvim.vim
elseif has('nvim')
  source ~/.config/m-lima/vim/plugins_nvim_old.vim
else
  source ~/.config/m-lima/vim/plugins_vim.vim
endif

" Functions
source ~/.config/m-lima/vim/functions.vim
