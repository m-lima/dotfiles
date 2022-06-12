""""""""""""""""""""
" Coloring config
""""""""""""""""""""

syntax enable

" Highlight the cursor line
set cul

" Force true color on Vim
if !has('nvim') && !has('gui_running') && &term =~ '^\%(alacritty\|screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" colorscheme grayalt
colorscheme simpalt
