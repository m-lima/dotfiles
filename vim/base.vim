""""""""""""""""""""
" Base config
""""""""""""""""""""

" Fix the backspace
set backspace=indent,eol,start

" Better search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Leader mapping
let mapleader = ","
let g:mapleader = ","

" Mouse support
set mouse=a

" Numbering
set number
set relativenumber

" Show white spaces
exec "set listchars=tab:\uB7\uA0,trail:\uAB,nbsp:\u268B"
set list

" Identation
set autoindent
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

" Give some room at top and bottom when scrolling
set scrolloff=4

" Timeout length for command sequences
set timeoutlen=400

" Show suggestions on top
set wildmenu
