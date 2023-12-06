""""""""""""""""""""
" Mapping config
""""""""""""""""""""

" We use ":" way more than ";"
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

" We use ESC way more than "\"
inoremap \ <Esc>
inoremap <C-\> \
vnoremap \ <Esc>
vnoremap <C-\> \

" Configure term "quit insert mode"
if has('nvim')
  tnoremap <C-\> <C-\><C-n>
endif

" Y should follow the pattern and yank until the end
nnoremap Y y$

" Copy to unnamed register
nnoremap gyy "+yy
vnoremap gy "+y

" Clean line
nnoremap de 0D

" Add new line
nnoremap U O<Esc>
nnoremap K o<Esc>

" Move text
nnoremap <silent> <C-h> :m .+1<CR>
nnoremap <silent> <C-l> :m .-2<CR>
vnoremap <silent> <C-h> :m '>+1<CR>gv
vnoremap <silent> <C-l> :m '<-2<CR>gv

" Remove the search highlights
nnoremap <silent> <leader>h :noh<CR>

" Lock the cursor to the middle of the screen
nnoremap <silent> <leader>z :let &scrolloff=999-&scrolloff<CR>

" More sensible scrolling
noremap <C-E> 5<C-E>
noremap <C-Y> 5<C-Y>

" Navigate through panes
noremap gh <C-W>h
noremap gj <C-W>j
noremap gk <C-W>k
noremap gl <C-W>l

" Navigate through tabs
noremap <silent> ]t gt
noremap <silent> [t gT

" Navigate through buffers
noremap <expr><silent> ]B ':' . v:count . 'bn<CR>'
noremap <expr><silent> [B ':' . v:count . 'bp<CR>'
noremap <silent> [vb :vs #<CR>

" Close buffer
" TODO: This is broken (when using NERDTree at least)
noremap <expr><silent> ][B expand('#') ? ':b #<CR>:bwipe #<CR>' : ':bp<CR>:bwipe #<CR>'

" I hate using ^ and $
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" Toggle relative numbering
noremap <leader>l :set rnu!<CR>

" Global modify
nnoremap <leader>c :%s//gc<LEFT><LEFT><LEFT>

" Current selection modify
vnoremap <leader>c :s//g<LEFT><LEFT>

" Current line modify
nnoremap <leader>C :s//g<LEFT><LEFT>

" Scrolling in the home row
nnoremap <C-j> 5<C-E>
nnoremap <C-k> 5<C-Y>
vnoremap <C-j> 5<C-E>
vnoremap <C-k> 5<C-Y>

" Resize
nnoremap <silent> gm :vertical resize -5<CR>
nnoremap <silent> g, :resize -5<CR>
nnoremap <silent> g. :resize +5<CR>
nnoremap <silent> g/ :vertical resize +5<CR>

" Incompatible with idea
if !has('ide')

  " Make asterisk case-sensitive and not move
  nnoremap <silent> * :let @/='\C\<' . expand('<cword>') . '\>'<CR>nN

  " Copy file name to clipboard
  nnoremap gyf :let @+=expand('%:p:~')<CR>:echo @+<CR>
  nnoremap gylf :let @+=expand('%:p:~') . ' +' . line('.')<CR>:echo @+<CR>
  nnoremap gyF :let @+=expand('%:p:.')<CR>:echo @+<CR>
  nnoremap gyg :let @+=trim(system('git remote get-url origin')) . '/blob/master/' . expand('%:p:.')<CR>:echo @+<CR>
endif
