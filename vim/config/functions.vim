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
function! s:highlightColumn(...) abort
  if s:highlightingColumn && !a:0
    let s:highlightingColumn = 0
    match OverLength //
    echo 'Column overlength highlight: off'
  else
    let s:highlightingColumn = 1
    if !exists('w:highlightColumnWidth')
      let w:highlightColumnWidth = 100
    endif
    if a:0
      let w:highlightColumnWidth = w:highlightColumnWidth + a:1
    endif
    execute 'match OverLength /\%' . (w:highlightColumnWidth + 1). 'v.\+/'
    echo 'Column overlength highlight: ' . w:highlightColumnWidth
  endif
endfunction

" Prepare the coloring
highlight OverLength ctermbg=darkred guibg=#A00000

" Map to a short hand
nnoremap <silent> <Leader>ww :call <SID>highlightColumn()<CR>
nnoremap <silent> <Leader>wq :call <SID>highlightColumn(-10)<CR>
nnoremap <silent> <Leader>we :call <SID>highlightColumn(+10)<CR>
let s:highlightingColumn = 0

" Show current highlight rules for cursor
" TODO: Does not work with TreeSitter
function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
nnoremap <leader>hi :call SynStack()<CR>

""""" Below this point be quasi-plugins

""" List TODOs
" " TODO: This references a plugin!! Make into a plugin?
" if executable('node')
"   function! s:toggle_todo()
"     cgetexpr system('rg -s --trim --vimgrep TODO')
"     CocCommand fzf-preview.QuickFix --add-fzf-arg="+s" --add-fzf-arg=--prompt="TODO> "
"   endfunction
" else
"   function! s:toggle_todo()
"     if &ft == 'qf'
"       ccl
"     else
"       cgetexpr system('rg -s --trim --vimgrep TODO')
"       call setqflist([], 'a', {'title': 'TODO'})
"       cope
"     endif
"   endfunction
" endif
"
" " Map to <leader>t
" nnoremap <silent> <Leader>t :call <SID>toggle_todo()<CR>

" TODO: Save all buffers into context

""" QML support
" TODO: This references a plugin!! Make into a plugin?
if executable('qmlformat')
  function! s:formatQml()
    let prev_view=winsaveview()
    call system('qmlformat -i -w ' . &tabstop . ' ' . expand('%'))
    e %

    " This autocmd comes after GitGutter's autocmd
    " This is on purpose, so that functions.vim can refer to plugins
    " Therefore, here GitGutter gets reloaded with the formatted buffer
    GitGutter
    call winrestview(prev_view)
  endfunction

  augroup functionsQmlFormat
    autocmd!
    autocmd BufWritePost *.qml call <SID>formatQml()
  augroup END
endif

" Disabled because it breaks quickfix
" TODO: Move it to a plugin that loads on modifiable
" """ Insert into scope
" function! s:insertIntoScope()
"   " (  40
"   " )  41
"   " { 123
"   " } 125
"   " [  91
"   " ]  93
"   let cur_char = strgetchar(getline('.')[col('.') - 1:], 0)
"   if (cur_char == 123 && strgetchar(getline('.')[col('.'):], 0) == 125)
"         \ || (cur_char == 40 && strgetchar(getline('.')[col('.'):], 0) == 41)
"         \ || (cur_char == 91 && strgetchar(getline('.')[col('.'):], 0) == 93)
"     call feedkeys("a\<CR>\<ESC>O")
"   elseif (cur_char == 125 && strgetchar(getline('.')[col('.') - 2:], 0) == 123)
"         \ || (cur_char == 41 && strgetchar(getline('.')[col('.') - 2:], 0) == 40)
"         \ || (cur_char == 93 && strgetchar(getline('.')[col('.') - 2:], 0) == 91)
"     call feedkeys("i\<CR>\<ESC>O")
"   endif
" endfunction
" nnoremap <silent> <CR> :call <SID>insertIntoScope()<CR>
