if has('win32')
  source $VIMRUNTIME/mswin.vim
endif

if exists(':GuiFont')
  GuiFont! DejaVuSansMono NF
endif

if exists(':GuiTabline')
  GuiTabline 0
endif

if exists(':GuiTabline')
  GuiTabline 0
endif

nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
