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

" Use ESC to exit insert mode in :term
if has("nvim")
  tnoremap <Esc> <C-\><C-n>
endif

" Copy line
nnoremap yp yyp

" Y should follow the pattern and yank until the end
nnoremap Y y$

" Copy to unnamed register
nnoremap gY "*y$
nnoremap gyy "*yy
vnoremap gy "*y

" Clean line
nnoremap de 0D

" Remove the search highlights
nnoremap <silent> <Leader>h :noh<CR>

" Lock the cursor to the middle of the screen
nnoremap <silent> <Leader>z :let &scrolloff=999-&scrolloff<CR>

" More sensible scrolling
noremap <C-E> 3<C-E>
noremap <C-Y> 3<C-Y>

" Enter adds a line below
nnoremap <CR> o<Esc>
" | adds a line above
nnoremap \| O<Esc>

" Navigate through panes
noremap gh <C-W>h
noremap gj <C-W>j
noremap gk <C-W>k
noremap gl <C-W>l

" I hate using ^ and $
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" Toggle relative numbering
noremap <Leader>r :set rnu!<CR>

" Global modify [Shift-S]
nnoremap S :%s//gc<LEFT><LEFT><LEFT>

" Current selection modify [Shift-S]
vnoremap S :s//g<LEFT><LEFT>

" Current line modify [Control-S]
nnoremap <C-S> :s//g<LEFT><LEFT>

" Grep current directory
nnoremap ? :grep '' %:p:h/*<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>

if &diff
  map ] ]c
  map [ [c
  hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
  hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
  hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif

" Scrolling using Ctrl
nnoremap <C-j> 5<C-E>
nnoremap <C-k> 5<C-Y>
vnoremap <C-j> 5<C-E>
vnoremap <C-k> 5<C-Y>

if has('macunix')
  " Get a proper delete on Mac
  imap <C-d> <Del>
elseif has('unix')
  " Mapping crude mouse wheel escape codes
  inoremap <Esc>[62~ <C-X><C-E>
  inoremap <Esc>[63~ <C-X><C-Y>
  nnoremap <Esc>[62~ <C-E>
  nnoremap <Esc>[63~ <C-Y>
endif

