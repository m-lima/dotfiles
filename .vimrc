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

" Language
" Plugin 'Valloric/YouCompleteMe'
if has("lua")
  Plugin 'shougo/neocomplete'
endif
Plugin 'fatih/vim-go'
Plugin 'lambdatoast/elm.vim'
" Plugin 'justmao945/vim-clang'

" Compose
" Plugin 'szw/vim-tags'
Plugin 'tpope/vim-surround'       " s
" Plugin 'gavinbeatty/dragvisuals.vim'

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
set noshowmode

" Vim-tags
" let g:vim_tags_auto_generate = 0

" let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
" let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

" Fugitive
" if has('win32')
" let g:fugitive_git_executable = 'C:\Users\mflim_000\AppData\Local\GitHub\Portab~1\cmd\git.exe'
" endif

" Go-Vim
let g:go_fmt_fail_silently = 1

" NeoComplete
if has("lua")
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
endif

""""""""""""""""""""
" Base config
""""""""""""""""""""

source ~/.vimrc.base

""""""""""""""""""""
" Vim config
""""""""""""""""""""

highlight OverLength ctermbg=darkred guibg=#A00000
let g:HighlightingColumn=0


""""""""""""""""""""
" Functions
""""""""""""""""""""

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! HighlightColumn()
  if g:HighlightingColumn
    let g:HighlightingColumn = 0
    match OverLength //
  else
    let g:HighlightingColumn = 1
    match OverLength /\%81v.\+/
  endif
endfunction

""""""""""""""""""""
" Mapping config
""""""""""""""""""""

nnoremap <Leader>c :call HighlightColumn()<CR>

""""""""""""""""""""
" Plugin mappings
""""""""""""""""""""

" NerdTree
nmap <Leader>n ;NERDTreeToggle<CR>
let NERDTreeMapOpenInTab='<CR>'

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

" NeoComplete
if has("lua")
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
endif

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
