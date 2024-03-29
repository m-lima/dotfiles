""""""""""""""""""""
" Options config
""""""""""""""""""""

" Don't make noise
set belloff=all

" Don't show mode
if has('nvim')
  set noshowmode
else
  set laststatus=2
endif

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
if has('nvim')
  set undodir=~/tmp/nvim_undo
else
  set undodir=~/tmp/vim_undo
endif

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
set timeoutlen=600

" Timeout for update (e.g. CursorHold)
set updatetime=500

" Show suggestions on top
set wildmenu

" UTF
set encoding=utf-8

" Netrw (folder view)
let netrw_banner = 0

" Pyenv root
if filereadable(expand('$HOME/code/python/env/vim/bin/python'))
  let python3_host_prog = expand('$HOME/code/python/env/vim/bin/python')
endif

" Allow stepping away from buffer without saving
set hidden

" Flash yanked text
if has('nvim')
  augroup optionsYankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
endif

if has('autocmd')
  " Do not add comment when using 'o'
  " Needs to be an autocmd because `ftplugin` of multiple filetypes set this
  " value
  augroup optionsOverruleFileTypesOptions
    autocmd!
    autocmd BufEnter * set formatoptions-=o
  augroup END

  " Personal help files
  augroup optionsHelpFile
    autocmd!
    autocmd BufRead *.help set tw=78 ts=8 ft=help norl
  augroup END

  " Send quickfix to the bottom with full width
  augroup optionsQuifixBottom
    autocmd!
    autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif
  augroup END
endif
