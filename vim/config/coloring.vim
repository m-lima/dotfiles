""""""""""""""""""""
" Coloring config
""""""""""""""""""""

syntax enable

" Highlight the cursor line
set cul

" Force true color on Vim
if !has('nvim') && !has('gui_running')
  if &term =~ '^alacritty'
    let &term = "xterm-256color"
  elseif &term =~  '^\%(screen\|tmux\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
endif

" colorscheme grayalt
colorscheme simpalt

" Create CursorHidden
if has('nvim-0.7')
  highlight CursorHidden guifg=white ctermfg=white guibg=white ctermbg=white blend=100
endif
