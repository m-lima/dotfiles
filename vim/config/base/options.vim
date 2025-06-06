""""""""""""""""""""
" Options config
""""""""""""""""""""

" Don't make noise
set belloff=all

" Always show status
set laststatus=2

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

" More sensible splitting
set splitright
set splitbelow

" Leader mapping
let mapleader = ' '
let maplocalleader = ','

" Mouse support
set mouse=a

" Numbering
set number
set relativenumber

" Show white spaces (in an exec to escape the caracters)
exec "set listchars=tab:\uB7\uA0,trail:\uAB,nbsp:\u203F"
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
set timeoutlen=600

" Timeout for update (e.g. CursorHold)
set updatetime=500

" Show suggestions on top
set wildmenu

" UTF
set encoding=utf-8

" Netrw (folder view)
let netrw_banner = 0

" Allow stepping away from buffer without saving
set hidden
