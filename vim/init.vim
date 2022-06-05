" Base config
source ~/.config/m-lima/vim/base.vim

" Coloring
source ~/.config/m-lima/vim/coloring.vim

" Plugins
if has('nvim')
  " TODO: Whenever we're ready!
  " source ~/.config/m-lima/vim/plugins_nvim.vim
  source ~/.config/m-lima/vim/plugins_nvim_ongoing.vim
else
  source ~/.config/m-lima/vim/plugins_vim.vim
endif

" Functions
source ~/.config/m-lima/vim/functions.vim
