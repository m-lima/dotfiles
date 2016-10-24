set nocompatible              " be iMproved, required
filetype off                  " required

set encoding=utf-8

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Visual
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Util
Plugin 'Repeat.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'kana/vim-textobj-user'
" Plugin 'justmao945/vim-clang'
" Plugin 'Valloric/YouCompleteMe'

" Compose
" Plugin 'szw/vim-tags'
Plugin 'tpope/vim-surround'
Plugin 'gavinbeatty/dragvisuals.vim'

" Verbs
Plugin 'tpope/vim-commentary'     " gc
Plugin 'ReplaceWithRegister'      " gr

" Text objects
Plugin 'kana/vim-textobj-line'    " l
Plugin 'kana/vim-textobj-indent'  " i
Plugin 'kana/vim-textobj-entire'  " e
Plugin 'glts/vim-textobj-comment' " c

call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""
" Plugin configs
""""""""""""""""""""

" Airline
let g:airline_powerline_fonts = 1
let g:airline_theme='badwolf'

" Vim-tags
" let g:vim_tags_auto_generate = 0

" let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
" let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

" Fugitive
" if has('win32')
  " let g:fugitive_git_executable = 'C:\Users\mflim_000\AppData\Local\GitHub\Portab~1\cmd\git.exe'
" endif

""""""""""""""""""""
" Vim config
""""""""""""""""""""

syntax enable
set autoindent
set smartindent

set backspace=indent,eol,start
set clipboard=unnamed

set incsearch
set ignorecase
set smartcase
set hlsearch

set laststatus=2

let mapleader = ","
let g:mapleader = ","

set mouse=a

set number
set relativenumber

exec "set listchars=tab:\uB7\uA0,trail:\uAB,nbsp:\u268B"
set list

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

set scrolloff=4

set timeoutlen=400

if has('win32')
  if !has("gui_running")
    " set term=pcansi
    " set t_Co=256
  endif

  " set shell=powershell
  " set shellcmdflag=-command
  " set shell=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
else
  " if has('macunix')
  " elseif has('unix')
  " endif
endif

""""""""""""""""""""
" Functions
""""""""""""""""""""

" function! NumberToggle()
"   if(&relativenumber == 1)
"     set number
"   else
"     set relativenumber
"   endif
" endfunc

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

""""""""""""""""""""
" Mapping config
""""""""""""""""""""

" nnoremap <C-j> :m .+1<CR>==
" nnoremap <C-k> :m .-2<CR>==
" inoremap <C-j> <Esc>:m .+1<CR>==gi
" inoremap <C-k> <Esc>:m .-2<CR>==gi
" vnoremap <C-j> :m '>+1<CR>gv=gv
" vnoremap <C-k> :m '<-2<CR>gv=gv

" nnoremap <C-l> :delete<CR>:put!<CR>:put<CR>==
" inoremap <C-l> <Esc>:delete<CR>:put!<CR>:put<CR>==gi
" vnoremap <C-l> :delete<CR>:put!<CR>:put<CR>v=v

" nnoremap <C-S-j> :delete<CR>:put!<CR>:put!<CR>==
" nnoremap <C-S-k> :delete<CR>:put!<CR>:put<CR>== 
" inoremap <S-C-j> <Esc>:m .+1<CR>==gi
" inoremap <S-C-k> <Esc>:m .-2<CR>==gi
" vnoremap <C-J> :delete<CR>:put!<CR>:put!<CR>gv=gv
" vnoremap <C-K> :delete<CR>:put!<CR>:put<CR>gv=gv 

" nnoremap <C-n> :call NumberToggle()<CR>

nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

inoremap \ <Esc>
inoremap <C-\> \
vnoremap \ <Esc>
vnoremap <C-\> \

nnoremap yp Yp

nnoremap <Leader>h :noh<CR>

nnoremap <Leader>z :let &scrolloff=999-&scrolloff<CR>

noremap <C-E> 3<C-E>
noremap <C-Y> 3<C-Y>

nnoremap <CR> o<Esc>
nnoremap \| O<Esc>

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

""""""""""""""""""""
" Plugin mappings
""""""""""""""""""""

" NerdTree
  nmap <Leader>n ;NERDTreeToggle<CR>

  " Quit if only NERDTree is left
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

  " Open NERDTree if no file is specified
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Dragging Visuals
  vmap <expr> <LEFT> DVB_Drag('left')
  vmap <expr> <RIGHT> DVB_Drag('right')
  vmap <expr> <UP> DVB_Drag('up')
  vmap <expr> <DOWN> DVB_Drag('down')
  vmap <expr> D DVB_Duplicate()

""""""""""""""""""""
" Tips
""""""""""""""""""""
"
" :w<CR> :e #         [Saves and open last save]
" s                   [Changes character]
" :noh                [Turn highlight off]
" :vert res <NUM>     [Resize split vertically to N]
" gg=G                [Indent the whole file]
" ~                   [Toggle case]
" ''                  [Go back to previous position]

" has("win32")        [Windows]
" has("unix")         [Unix and Mac]
" has("macunix")      [Just mac]

" [Goto line]
" 42G
" 42gg
" :42<CR>

" [c                  [Previous diff]
" ]c                  [Next diff]
" do                  [Diff obtain]
" dp                  [Diff put]

" s                   [Surround]
" cs                  [Change surround]
" ds                  [Delete surround]
" ys                  [Add surround]
