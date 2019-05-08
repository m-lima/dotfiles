""""""""""""""""""""
" Functions
""""""""""""""""""""

""" Show differences from saved
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

" Map to a command
com! DiffSaved call s:DiffWithSaved()

""" Show extended lines
function! HighlightColumn()
  if g:HighlightingColumn
    let g:HighlightingColumn = 0
    match OverLength //
  else
    let g:HighlightingColumn = 1
    match OverLength /\%101v.\+/
  endif
endfunction

" Prepare the coloring
highlight OverLength ctermbg=darkred guibg=#A00000
let g:HighlightingColumn=0

" Map to a short hand
nnoremap <Leader>c :call HighlightColumn()<CR>

