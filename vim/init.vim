" Base config
source ~/.config/m-lima/vim/base.vim

" Coloring
source ~/.config/m-lima/vim/coloring.vim

" Plugins
if has('nvim-0.7')
  source ~/.config/m-lima/vim/plugins/nvim_latest.vim
elseif has('nvim-0.5')
  source ~/.config/m-lima/vim/plugins/nvim_coc.vim
elseif has('nvim')
  source ~/.config/m-lima/vim/plugins/compatible_full.vim
else
  source ~/.config/m-lima/vim/plugins/compatible_minimal.vim
endif

" Functions
source ~/.config/m-lima/vim/functions.vim
