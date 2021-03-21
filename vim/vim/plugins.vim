""""""""""""""""""""
" Plugins install
""""""""""""""""""""

if executable('rustc')
  if executable('racer')
    let s:rust = 2
  else
    let s:rust = 1
  endif
endif

if executable('npm')
  let s:npm = 1
endif

if executable('clang')
  let s:clang = 1
endif

if executable('go')
  let s:go = 1
endif

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

""" Util
Plug 'kien/ctrlp.vim'
Plug 'jistr/vim-nerdtree-tabs', { 'on': ['NERDTree', 'NERDTreeTabsOpen', 'NERDTreeToggle','NERDTreeTabsToggle'] }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'ryanoasis/vim-devicons'
" Plug 'terryma/vim-multiple-cursors'
Plug 'aserebryakov/vim-todo-lists'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

""" Languages
if has('node')
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  Plug 'puremourning/vimspector', { 'on': [ '<Plug>VimspectorLaunch', '<Plug>VimspectorToggleBreakpoint' ] }
else

  " Go
  if exists('s:go')
    " Language server
    Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoInstallBinaries' }
  endif

  " JS stuff
  if exists('s:npm')
    " Javascript highlight
    Plug 'pangloss/vim-javascript', { 'for': 'javascript' }

    " Typescript highlight
    Plug 'HerringtonDarkholme/yats.vim', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ] }

    " Language server
    if has('nvim')
      Plug 'mhartington/nvim-typescript', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ], 'do': './install.sh' }
    else
      Plug 'shougo/vimproc.vim', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ], 'do': 'make' }
      Plug 'quramy/tsuquyomi', { 'for': [ 'typescript', 'typescriptreact', 'typescript.tsx' ] }
    endif
  endif

  " Rust
  if exists('s:rust')
    " Rust commands
    Plug 'rust-lang/rust.vim', { 'for': 'rust' }

    if s:rust > 1
      " Language server
      Plug 'racer-rust/vim-racer', { 'for': 'rust' }
    endif
  endif

  " Nginx
  Plug 'vim-scripts/nginx.vim'

  """ Language helpers

  " Lint
  if has('nvim')
    Plug 'neomake/neomake'
  else
    Plug 'vim-syntastic/syntastic'
  endif

  " Completion
  if has('nvim')
    if has('python3')
      Plug 'shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

      if exists('s:clang')
        Plug 'zchee/deoplete-clang', { 'for': ['cpp', 'c'] }
      endif
    endif
  else
    if has('lua')
      Plug 'Quramy/tsuquyomi', { 'for': 'typescript', 'do': 'make' }
      Plug 'shougo/neocomplete'
    endif
  endif
endif

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

""" Vim-go
let g:go_fmt_fail_silently = 1
let g:go_doc_keywordprg_enabled = 0

""" Vim-commentary
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType cpp,hpp,c,h,cc,hh,cl,tf setlocal commentstring=//\ %s
autocmd FileType toml setlocal commentstring=#\ %s

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
autocmd bufenter * if (winnr("$") == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif

""" Fugitive
nnoremap <Leader>b :Gblame<CR>

""" GitGutter
nnoremap <Leader>g :GitGutterToggle<CR>

" Increase the update speed to allow faster signing
" set updatetime=400
" Optionally, gitgutter can run on saves:
autocmd BufWritePost * GitGutter
" In the file: .vim/after/plugin/gitgutter.vim
" autocmd! gitgutter CursorHold,CursorHoldI

" Don't load straightaway
" let g:gitgutter_enabled = 0

""" Vim-rooter
let g:rooter_patterns = ['.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'Cargo.toml', 'build.gradle', 'CMakeLists.txt']

""" Vim-commentary
" Do not add comment when using 'o'
autocmd FileType * setlocal formatoptions-=o

""" Completion navigation overload
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

if has('node')

  let g:coc_global_extensions = [ "coc-rust-analyzer", "coc-go", "coc-json", "coc-tsserver" ]

  function! s:show_documentation()
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Definition
  nmap     <silent> gd         <Plug>(coc-definition)
  nnoremap <silent> gD         :call <SID>show_documentation()<CR>
  nmap     <silent> <leader>e  <Plug>(coc-rename)
  nmap     <silent> <leader>E  <Plug>(coc-refactor)
  nmap     <silent> <leader>f  <Plug>(coc-references)

  " Pop-up scrolling
  " nnoremap <expr><C-k> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  " nnoremap <expr><C-j> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  " inoremap <expr><C-k> coc#float#has_scroll() ? coc#float#scroll(1) : "\<Right>"
  " inoremap <expr><C-j> coc#float#has_scroll() ? coc#float#scroll(0) : "\<Left>"

  " More readable colors
  highlight link CocErrorSign DiffDelete
  highlight link CocWarningSign DiffChange

  " VimInspector
  nmap <F2> <Plug>VimspectorLaunch
  nnoremap <silent> <leader><F2> :VimspectorReset<CR>
  nmap <F11> <Plug>VimspectorReset
  nmap <F5> <Plug>VimspectorContinue
  nmap <F4> <Plug>VimspectorRestart
  nmap <F3> <Plug>VimspectorStop
  nmap <F6> <Plug>VimspectorRunToCursor
  nmap <F7> <Plug>VimspectorStepInto
  nmap <F8> <Plug>VimspectorStepOver
  nmap <F9> <Plug>VimspectorToggleBreakpoint
  nmap <F10> <Plug>VimspectorBalloonEval
  xmap <F10> <Plug>VimspectorBalloonEval
else
  if has('nvim')
    if has('python3')

      """ Deoplete
      let g:deoplete#enable_at_startup = 1
      call g:deoplete#custom#option({'smart_case': v:true})

      " Golang
      if exists('s:go')
        call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
      endif

      " Clang
      if exists('s:clang')
        if has('win32')
        elseif has('macunix')
          let g:deoplete#sources#clang#libclang_path = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
          let g:deoplete#sources#clang#clang_header = '/Library/Developer/CommandLineTools/usr/lib/clang'
        else
          let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-4.0/lib/libclang.so.1'
          let g:deoplete#sources#clang#clang_header = '/usr/lib/llvm-4.0/lib/clang'
        endif
      endif

    endif
  else
    if has('lua')

      """ NeoComplete
      let g:neocomplete#enable_at_startup = 1
      let g:neocomplete#enable_smart_case = 1

    endif
  endif

  """ Rust
  if exists('s:rust')
    let g:rustfmt_autosave = 1

    if s:rust > 1
      augroup Racer
        autocmd!
        autocmd FileType rust nmap <buffer> gd         <Plug>(rust-def)
        autocmd FileType rust nmap <buffer> gD         <Plug>(rust-def-tab)
        autocmd FileType rust nmap <buffer> <leader>d  <Plug>(rust-doc)
        autocmd FileType rust nmap <buffer> <leader>D  <Plug>(rust-doc-tab)
      augroup END
    endif
  endif

  """ Javascript
  if exists('s:npm')
    if has('nvim')
      augroup Ts
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gd        :TSDef<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gD        :TSDefPreview<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> <leader>e :TSRename<CR>
      augroup END
    else
      let g:tsuquyomi_disable_quickfix = 1
      augroup Ts
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gd        :TsuDefinition<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gD        :TsuTypeDefinition<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nmap     <buffer> <leader>e <Plug>(TsuquyomiRenameSymbolC)
      augroup END
    endif
  endif

  if exists('s:go')
    autocmd FileType go nmap <buffer> <leader>e <Plug>(go-rename)
  endif

  """ Lint
  if has('nvim')

    call neomake#configure#automake('nrwi', 500)

    " Run `:Neomake clear` to clear the screen from Neomake
    let g:neomake_clear_maker = {}

    augroup neomake_highlights
      au!
      autocmd ColorScheme *
            \ highlight NeomakeVirtualtextError cterm=bold ctermfg=203 ctermbg=52 gui=bold guifg=#ff5f5f guibg=#5f0000 |
            \ highlight NeomakeVirtualtextWarning ctermfg=227 guifg=#ffff5f
    augroup END

    if exists('s:go')
      let g:neomake_go_enabled_makers = [ 'go' ]
    endif

    if exists('s:npm')
      " TODO: linting in typescript with neomake is not setup right yet
    endif
  else
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_loc_list_height = 5
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0

    let g:syntastic_error_symbol = ''
    let g:syntastic_warning_symbol = ''
    let g:syntastic_style_error_symbol = ''
    let g:syntastic_style_warning_symbol = ''

    highlight link SyntasticErrorSign DiffDelete
    highlight link SyntasticWarningSign DiffChange
    highlight link SyntasticStyleErrorSign DiffDelete
    highlight link SyntasticStyleWarningSign DiffChange

    if exists('s:npm')
      let g:syntastic_typescript_checkers = [ 'tsuquyomi' ]
      let g:syntastic_typescriptreact_checkers = [ 'tsuquyomi' ]
    endif

    if exists('s:go')
      let g:syntastic_go_checkers = [ 'go' ]
    endif
  endif

  " Rust
  if exists('s:rust')
    let g:rust_cargo_check_tests = 1
    let g:rust_cargo_check_examples = 1
  endif
endif

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

" va}a}a}...a}        [Select larger and larger scope]

" has('win32')        [Windows]
" has('unix')         [Unix and Mac]
" has('macunix')      [Just mac]
" executable('racer') [Exectutable is found]

""" Go to line
" 42G
" 42gg
" :42<CR>
" 80%

""" VimGutter
" <leader>hp          [Preview hunk changes]
" <leader>hu          [Undo hunk changes]
" <leader>hs          [Stage hunk changes]
" [c                  [Previous hunk]
" ]c                  [Next hunk]

""" VimDiff
" [c                  [Previous diff]
" ]c                  [Next diff]
" do                  [Diff obtain]
" dp                  [Diff put]

""" Surround
" s                   [Surround]
" cs                  [Change surround]
" ds                  [Delete surround]
" ys                  [Add surround]

""" Neomake
" :Neomake clear      Clear all neomake marks
