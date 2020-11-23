""""""""""""""""""""
" Options config
""""""""""""""""""""

" Don't show mode
set noshowmode

" No *.swp file
set noswapfile

" Fix the backspace
set backspace=indent,eol,start

" Better search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Persistent undo
set undofile
set undodir=~/tmp/vim_undo

" More sensible splitting
set splitright
set splitbelow

" Leader mapping
let mapleader = ","
let g:mapleader = ","

" Mouse support
set mouse=a

" Numbering
set number
set relativenumber

" Show white spaces (in an exec to escape the caracters)
exec "set listchars=tab:\uB7\uA0,trail:\uAB,nbsp:\u268B"
set list

" Do not add comment when using 'o'
autocmd FileType * setlocal formatoptions-=o

" Identation
set autoindent
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
" But go is special
autocmd FileType go setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab

" Give some room at top and bottom when scrolling
set scrolloff=4

" Timeout length for command sequences
set timeoutlen=400

" Show suggestions on top
set wildmenu

" File types
autocmd BufRead,BufNewFile *.cl set filetype=c
autocmd BufRead,BufNewFile *.toml set filetype=toml

" UTF
set encoding=utf-8

" Netrw (folder view)
let g:netrw_banner = 0

" Personal help files
autocmd BufRead *.help set tw=78 ts=8 ft=help norl

" Pyenv root
let g:python3_host_prog = '$HOME/code/python/env/vim/bin/python'

" Allow stepping away from buffer without saving
set hidden
