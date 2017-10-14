""""""""""""""""""""
" Mapping config
""""""""""""""""""""

nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

inoremap \ <Esc>
inoremap <C-\> \
vnoremap \ <Esc>
vnoremap <C-\> \

nnoremap yp yyp
nnoremap Y y$
nnoremap de 0D

nnoremap <silent> <Leader>h :noh<CR>

nnoremap <silent> <Leader>z :let &scrolloff=999-&scrolloff<CR>

noremap <C-E> 3<C-E>
noremap <C-Y> 3<C-Y>

nnoremap <CR> o<Esc>
nnoremap \| O<Esc>

noremap gh <C-W>h
noremap gj <C-W>j
noremap gk <C-W>k
noremap gl <C-W>l

nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

noremap <Leader>r :set rnu!<CR>

if has('win32')
  nnoremap <M-j> 5<C-E>
  nnoremap <M-k> 5<C-Y>
  vnoremap <M-j> 5<C-E>
  vnoremap <M-k> 5<C-Y>

  nnoremap S :%s//gc<LEFT><LEFT><LEFT>
  nnoremap <M-s> :s//g<LEFT><LEFT>

  vnoremap <M-s> :s//g<LEFT><LEFT>
else
  if has('macunix')
    imap <C-d> <Del>

    nnoremap ∆ 5<C-E>
    nnoremap ˚ 5<C-Y>
    vnoremap ∆ 5<C-E>
    vnoremap ˚ 5<C-Y>

    nnoremap S :%s//gc<LEFT><LEFT><LEFT>
    nnoremap ß :s//g<LEFT><LEFT>

    vnoremap ß :s//g<LEFT><LEFT>
  elseif has('unix')
    nnoremap ∆ 5<C-E>
    nnoremap ˚ 5<C-Y>
    vnoremap ∆ 5<C-E>
    vnoremap ˚ 5<C-Y>

    nnoremap ß :s//g<LEFT><LEFT>
    vnoremap ß :s//g<LEFT><LEFT>

    nnoremap <Esc>j 5<C-E>
    nnoremap <Esc>k 5<C-Y>
    vnoremap <Esc>j 5<C-E>
    vnoremap <Esc>k 5<C-Y>

    nnoremap S :%s//gc<LEFT><LEFT><LEFT>
    nnoremap <Esc>s :s//g<LEFT><LEFT>

    vnoremap <Esc>s :s//g<LEFT><LEFT>

    inoremap <Esc>[62~ <C-X><C-E>
    inoremap <Esc>[63~ <C-X><C-Y>
    nnoremap <Esc>[62~ <C-E>
    nnoremap <Esc>[63~ <C-Y>
  endif
endif

