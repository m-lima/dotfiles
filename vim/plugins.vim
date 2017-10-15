""""""""""""""""""""
" Plugins install
""""""""""""""""""""

call plug#begin()

""" Visual
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

""" Util
Plug 'tpope/vim-repeat'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeTabsOpen', 'NERDTreeToggle','NERDTreeTabsToggle'] }
Plug 'jistr/vim-nerdtree-tabs', { 'on': ['NERDTree', 'NERDTreeTabsOpen', 'NERDTreeToggle','NERDTreeTabsToggle'] }
Plug 'kana/vim-textobj-user'

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-line'           " l
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

""" Completion
"if has("lua")
  "Plugin 'shougo/neocomplete'
"endif
if has("python3")
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'zchee/deoplete-clang', { 'for': 'cpp' }
  Plug 'zchee/deoplete-go'
endif

""" Languages
Plug 'fatih/vim-go'

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

""" Vim-go
let g:go_fmt_fail_silently = 1

""" Vim-commentary
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType cpp,hpp,c,h,cc,hh,cl setlocal commentstring=//\ %s

""" Vim-airline
let g:airline_powerline_fonts = 1
let g:airline_theme='badwolf'
let g:airline#extensions#tabline#enabled = 1
set noshowmode

" Always show status
set laststatus=2

""" NerdTree
nnoremap <Leader>n :NERDTreeTabsToggle<CR>
let NERDTreeMapOpenInTab='<CR>'

" Quit if only NERDTree is left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" NeoComplete
" let g:neocomplete#enable_at_startup = 1
" let g:neocomplete#enable_smart_case = 1

""" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
if has('macunix')
  let g:deoplete#sources#clang#libclang_path = "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib"
  let g:deoplete#sources#clang#clang_header = "/Library/Developer/CommandLineTools/usr/lib/clang"
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
