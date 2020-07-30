""""""""""""""""""""
" Plugins install
""""""""""""""""""""

call plug#begin()

""" Visual
if !exists('g:gui_oni')
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
endif

""" Dependencies
" Dependency for text objects
Plug 'kana/vim-textobj-user'
" Depenency for vim-scripts/ReplaceWithRegister
Plug 'tpope/vim-repeat'
" Dependency for jistr/vim-nerdtree-tabs
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeTabsOpen', 'NERDTreeToggle', 'NERDTreeTabsToggle'] }
" Dependency for tpope/fugitive (apparently not true)
" Plug 'tpope/vim-rhubarb'

""" Util
Plug 'kien/ctrlp.vim'
Plug 'jistr/vim-nerdtree-tabs', { 'on': ['NERDTree', 'NERDTreeTabsOpen', 'NERDTreeToggle','NERDTreeTabsToggle'] }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'ryanoasis/vim-devicons'
" Plug 'terryma/vim-multiple-cursors'

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
" Plug 'kana/vim-textobj-line'           " l
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

""" Languages

" Go
if executable('go')
  " Language server
  Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoInstallBinaries' }
endif

" JS stuff
if executable('npm')
  " Javascript highlight
  Plug 'pangloss/vim-javascript', { 'for': 'javascript' }

  " Typescript highlight
  Plug 'HerringtonDarkholme/yats.vim', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ] }

  " Language server
  Plug 'mhartington/nvim-typescript', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ], 'do': './install.sh' }
endif

" Rust
if executable('rustc')
  " Rust commands
  Plug 'rust-lang/rust.vim', { 'for': 'rust' }

  if executable('racer')
    " Language server
    Plug 'racer-rust/vim-racer', { 'for': 'rust' }
  endif
endif

" Nginx
Plug 'vim-scripts/nginx.vim'

""" Language helpers

" Syntax markers
Plug 'vim-syntastic/syntastic'

" Completion
if has("nvim")
  if has("python3")
    Plug 'shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    if executable('clang')
      Plug 'zchee/deoplete-clang', { 'for': ['cpp', 'c'] }
    endif
  endif
else
  if has("lua")
    Plug 'Quramy/tsuquyomi', { 'for': 'typescript', 'do': 'make' }
    Plug 'shougo/neocomplete'
  endif
endif

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

""" Vim-go
let g:go_fmt_fail_silently = 1

""" Vim-commentary
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType cpp,hpp,c,h,cc,hh,cl,tf setlocal commentstring=//\ %s

""" Vim-airline
if !exists('g:gui_oni')
  let g:airline_powerline_fonts = 1
  let g:airline_theme='deus'
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  set laststatus=2
else
  set noruler
  set laststatus=0
  set noshowcmd
endif

""" NerdTree
nnoremap <Leader>n :NERDTreeTabsToggle<CR>
" let NERDTreeMapOpenInTab='<CR>'
let NERDTreeMinimalUI=1

" Quit if only NERDTree is left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" Fugitive
nnoremap <Leader>b :Gblame<CR>

""" GitGutter
nnoremap <Leader>g :GitGutterToggle<CR>

" Increase the update speed to allow faster signing
set updatetime=400
" Optionally, gitgutter can run on saves:
" autocmd BufWritePost * GitGutter
" In the file: .vim/after/plugin/gitgutter.vim
" autocmd! gitgutter CursorHold,CursorHoldI

" Don't load straightaway
" let g:gitgutter_enabled = 0

""" Completion navigation overload
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

if has("nvim")
  if has("python3")

    """ Deoplete
    let g:deoplete#enable_at_startup = 1
    call g:deoplete#custom#option({'smart_case': v:true})

    " Golang
    if executable('go')
      call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    endif

    " Clang
    if executable('clang')
      if has('win32')
      elseif has('macunix')
        let g:deoplete#sources#clang#libclang_path = "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib"
        let g:deoplete#sources#clang#clang_header = "/Library/Developer/CommandLineTools/usr/lib/clang"
      else
        let g:deoplete#sources#clang#libclang_path = "/usr/lib/llvm-4.0/lib/libclang.so.1"
        let g:deoplete#sources#clang#clang_header = "/usr/lib/llvm-4.0/lib/clang"
      endif
    endif

  endif
else
  if has("lua")

    """ NeoComplete
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1

  endif
endif

""" Rust
if executable('rustc')
  let g:rustfmt_autosave = 1

  if executable('racer')
    let g:racer_insert_paren = 1

    augroup Racer
      autocmd!
      autocmd FileType rust nmap <buffer> gd         <Plug>(rust-def)
      autocmd FileType rust nmap <buffer> gD         <Plug>(rust-def-tab)
      autocmd FileType rust nmap <buffer> <leader>gd <Plug>(rust-doc)
      autocmd FileType rust nmap <buffer> <leader>gD <Plug>(rust-doc-tab)
    augroup END
  endif
endif

""" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_error_symbol = ''
let g:syntastic_warning_symbol = ''
let g:syntastic_style_error_symbol = ''
let g:syntastic_style_warning_symbol = ''

highlight link SyntasticErrorSign DiffDelete
highlight link SyntasticWarningSign DiffChange
highlight link SyntasticStyleErrorSign DiffDelete
highlight link SyntasticStyleWarningSign DiffChange

" Rust
" Automatic

" Javascript
" ??

" CPP
" Automatic

" Go
if executable('go')
  let g:syntastic_go_checkers = ['go']
endif

""" Vim-commentary
" Do not add comment when using 'o'
autocmd FileType * setlocal formatoptions-=o

""""""""""""""""""""
" Tips
""""""""""""""""""""

" :checkhealth        Check the health of the plugins

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
"
" va}a}a}...a}        [Select larger and larger scope]
