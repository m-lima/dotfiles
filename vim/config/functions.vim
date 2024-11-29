""" Show extended lines
function! s:highlightColumn(...) abort
  if !exists('b:highlightColumnWidth')
    let b:highlightingColumn = 0
  endif

  if b:highlightingColumn && !a:0
    let b:highlightingColumn = 0
    match OverLength //
    echo 'Column overlength highlight: off'
  else
    let b:highlightingColumn = 1
    if !exists('b:highlightColumnWidth')
      if &textwidth
        let b:highlightColumnWidth = &textwidth
      else
        let b:highlightColumnWidth = 100
      endif
    endif
    if a:0
      let b:highlightColumnWidth = b:highlightColumnWidth + a:1
    endif
    execute 'match OverLength /\%' . (b:highlightColumnWidth + 1). 'v.\+/'
    echo 'Column overlength highlight: ' . b:highlightColumnWidth
  endif
endfunction

" Prepare the coloring
highlight OverLength ctermbg=darkred guibg=#A00000

" Map to a short hand
nnoremap <silent> <leader>ww :call <SID>highlightColumn()<CR>
nnoremap <silent> <leader>wq :call <SID>highlightColumn(-10)<CR>
nnoremap <silent> <leader>we :call <SID>highlightColumn(+10)<CR>
