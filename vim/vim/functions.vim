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

" Show current highlight rules for cursor
function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
nnoremap gm :call SynStack()<CR>

""" List TODOs
function! s:toggle_todo()
  if &ft == 'qf'
    ccl
  else
    cgetexpr system('rg -s --trim --vimgrep TODO')
    call setqflist([], 'a', {'title': 'TODO'})
    cope
  endif
endfunction

" Map to <leader>t
nnoremap <silent> <Leader>t :call <SID>toggle_todo()<CR>
