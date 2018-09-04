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

" File types
autocmd BufRead,BufNewFile *.ts set filetype=javascript
autocmd BufRead,BufNewFile *.cl set filetype=c

" UTF
set encoding=utf-8

" Netrw (folder view)
let g:netrw_banner = 0
