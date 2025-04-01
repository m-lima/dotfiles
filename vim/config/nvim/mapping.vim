" Configure term "quit insert mode"
tnoremap <C-\> <C-\><C-n>

" Make asterisk case-sensitive and not move
nnoremap <silent> * :let @/='\C\<' . expand('<cword>') . '\>'<CR>nN

" Copy file name to clipboard
nnoremap gyf :let @+=expand('%:p:.')<CR>:echo @+<CR>
nnoremap gyF :let @+=expand('%:p:~')<CR>:echo @+<CR>
nnoremap gyl :let @+=expand('%:p:.') . ' +' . line('.')<CR>:echo @+<CR>
nnoremap gyL :let @+=expand('%:p:~') . ' +' . line('.')<CR>:echo @+<CR>
nnoremap gyg :let @+=trim(system('git remote get-url origin')) . '/blob/master/' . expand('%:p:.')<CR>:echo @+<CR>

" Disabling conflicting defaults
" See https://neovim.io/doc/user/lsp.html#lsp-defaults
nunmap grn
nunmap gra
nunmap grr
nunmap gri
nunmap gO
iunmap <C-S>
