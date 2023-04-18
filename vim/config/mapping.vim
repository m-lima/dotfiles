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
if has("nvim")
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
nnoremap <silent> <C-h> <cmd>m .+1<CR>
nnoremap <silent> <C-l> <cmd>m .-2<CR>
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
noremap <expr><silent> ]B '<cmd>' . v:count . 'bn<CR>'
noremap <expr><silent> [B '<cmd>' . v:count . 'bp<CR>'

" Close buffer
" TODO: This is broken (when using NERDTree at least)
noremap <expr><silent> ][B expand('#') ? '<cmd>b #<CR><cmd>bwipe #<CR>' : '<cmd>bp<CR><cmd>bwipe #<CR>'

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

" TODO: Revise this.. It looks weird
if &diff
  map ] ]c
  map [ [c
  hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
  hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
  hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif

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

" Copy file name to clipboard
nnoremap gyf <cmd>let @+=expand('%:p:~')<CR>
nnoremap gyF <cmd>let @+=expand('%:p:.')<CR>
