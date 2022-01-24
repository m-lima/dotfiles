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

""" Dependencies
Plug 'kana/vim-textobj-user' " Dependency for text objects
Plug 'tpope/vim-repeat' " Depenency for vim-scripts/ReplaceWithRegister
Plug 'ryanoasis/vim-devicons'

""" Visual
if !exists('g:gui_oni')
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
endif

""" Util
Plug 'preservim/nerdtree', { 'on': [ 'NERDTree', 'NERDTreeToggle', 'NERDTreeFind' ] }
Plug 'xuyuanp/nerdtree-git-plugin', { 'on': [ 'NERDTree', 'NERDTreeToggle', 'NERDTreeFind' ] }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'aserebryakov/vim-todo-lists'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'unblevable/quick-scope'

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

""" Languages

" Simple syntax highlight for TOML
Plug 'cespare/vim-toml', { 'for': 'toml' }

" QML has no LSP
Plug 'peterhoeg/vim-qml', { 'for': 'qml' }

if has('node')

  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  Plug 'puremourning/vimspector', { 'on': [ '<Plug>VimspectorLaunch', '<Plug>VimspectorToggleBreakpoint' ] }

else

  " Regular fzf
  Plug 'junegunn/fzf.vim'

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
augroup pluginsVimComentary
  autocmd!

  " Do not add comment when using 'o'
  autocmd FileType * setlocal formatoptions-=o

  " Custom comment strings
  autocmd FileType cmake setlocal commentstring=#\ %s
  autocmd FileType cpp,hpp,c,h,cc,hh,cl,tf,zig setlocal commentstring=//\ %s
  autocmd FileType toml setlocal commentstring=#\ %s
augroup END

""" Vim-airline
if !exists('g:gui_oni')
  let g:airline_powerline_fonts = 1
  let g:airline_theme='deus'
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#tabline#show_tabs = 0
  let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|term://|undotree|vimfiler'
  set laststatus=2
else
  set noruler
  set laststatus=0
  set noshowcmd
endif

""" NerdTree
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''

function! s:toggle_nerdtree()
  if (exists('g:NERDTree') && g:NERDTree.IsOpen()) || !(&modifiable && !&diff && strlen(expand('%')) > 0 && bufname('%') !~ 'NERD_tree_\d\+')
    NERDTreeToggle
  else
    NERDTreeFind
  endif
endfunction

nnoremap <silent> <Leader>n :call <SID>toggle_nerdtree()<CR>
let NERDTreeMinimalUI=1

augroup pluginsNERDTree
  autocmd!

  " Quit if only NERDTree is left
  autocmd BufEnter * if (winnr("$") == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif

  " If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
  autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
      \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

  " " Sync NERDTree across tabs
  " autocmd BufWinEnter * if exists('g:NERDTree') | silent NERDTreeMirror | endif

  " Sync NERDTree with current buffer
  " [wincmd p] is equivalent to <C-w>p
  autocmd BufEnter * if &modifiable
        \ && !&diff
        \ && exists('g:NERDTree')
        \ && NERDTree.IsOpen()
        \ && strlen(expand('%')) > 0
        \ && bufname('%') !~ 'NERD_tree_\d\+'
        \ | NERDTreeFind | NERDTreeCWD | wincmd p | endif
augroup END

""" Fugitive
nnoremap <silent> <Leader>gb :Git blame<CR>

""" GitGutter
let g:gitgutter_map_keys = 0 " Disable default mappings
nnoremap <silent> <Leader>gg :GitGutterToggle<CR>
nnoremap <silent> <Leader>gs :GitGutterStageHunk<CR>
nnoremap <silent> <Leader>gu :GitGutterUndoHunk<CR>
nnoremap <silent> <Leader>gp :GitGutterPreviewHunk<CR>
nnoremap <silent> <Leader>gl :GitGutterQuickFix<CR>:copen<CR>
nnoremap <silent> <Leader>gf :GitGutterFold<CR>
nnoremap <silent> ]g         :GitGutterNextHunk<CR>
nnoremap <silent> [g         :GitGutterPrevHunk<CR>

augroup pluginVimGutter
  autocmd!
  autocmd BufWritePost * GitGutter
augroup END
" In the file: .vim/after/plugin/gitgutter.vim
" autocmd! gitgutter CursorHold,CursorHoldI

" Don't load straightaway
" let g:gitgutter_enabled = 0

""" Vim-rooter
let g:rooter_patterns = ['.vim/', '.git/', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'build.gradle', 'CMakeLists.txt']

""" Fzf
if has('node')

  """ Fzf-Preview
  " TODO: Use Delta
  " TODO: More git actions
  " TODO: Highlight matched text in line and in preview
  " TODO: Show processing, e.g. coc-references, in the statusline
  " TODO: Allow calling the preview without having to rewrite it (just reopen)
  " TODO: Diagnostics preview currently broken (fork/exec /bin/zsh: invalid argument)
  nnoremap <silent> <leader>mp     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
  nnoremap <silent> <leader>mf     :<C-u>CocCommand fzf-preview.DirectoryFiles<CR>
  nnoremap <silent> <leader>mb     :<C-u>CocCommand fzf-preview.Buffers<CR>
  nnoremap <silent> <leader>mB     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
  nnoremap <silent> <leader>mo     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>

  nnoremap <silent> <leader>mgs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
  nnoremap <silent> <leader>mga    :<C-u>CocCommand fzf-preview.GitActions<CR>
  nnoremap <silent> <leader>mg;    :<C-u>CocCommand fzf-preview.Changes<CR>

  nnoremap <silent> <leader>m/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
  nnoremap <silent> <leader>m8     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
  nnoremap          <leader>m*     :<C-u>Rg <C-r>=expand('<cword>')<CR><CR>
  nnoremap          ?              :<C-u>Rg<Space>

  nnoremap <silent> <leader>m<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
  nnoremap <silent> <leader>mt     :<C-u>CocCommand fzf-preview.BufferTags<CR>
  nnoremap <silent> <leader>mq     :<C-u>CocCommand fzf-preview.QuickFix<CR>
  nnoremap <silent> <leader>ml     :<C-u>CocCommand fzf-preview.LocationList<CR>

  command! -bang -nargs=* Rg CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--prompt="Rg> " <q-args>

  let g:fzf_preview_use_dev_icons = 1

  " TODO: Broken with the Coc version of fzf-preview :(
  if executable('delta')
    augroup pluginFzfPreview
      autocmd!
      autocmd User CocNvimInit once silent CocRestart
      autocmd User fzf_preview#coc#initialized call s:fzf_preview_settings()
    augroup END

    function! s:fzf_preview_settings() abort
      let g:fzf_preview_git_status_preview_command = "[[ $(git diff --cached -- {-1}) != \"\" ]] && git diff --cached --color=always -- {-1} | delta || " .
        \ "[[ $(git diff -- {-1}) != \"\" ]] && git diff --color=always -- {-1} | delta || " .
        \ g:fzf_preview_command
    endfunction
  endif
else

  """ Fzf.vim
  nnoremap ? :Rg<Space>

  nnoremap <C-B> :Buffers<CR>
  nnoremap <C-G> :GFiles<CR>
  nnoremap <C-F> :Files<CR>
  let g:fzf_layout = { 'down': '40%' }
endif

""" Quick-scope
let g:qs_highlight_on_keys = ['f', 'F']
highlight link QuickScopePrimary Visual
highlight link QuickScopeSecondary Search

if has('node')

  """ Coc
  let g:coc_global_extensions = [ 'coc-json' ]

  call add(g:coc_global_extensions, 'coc-fzf-preview')

  if executable('rustc')
    call add(g:coc_global_extensions, 'coc-rust-analyzer')
  endif

  if executable('go')
    call add(g:coc_global_extensions, 'coc-go')
  endif

  if executable('clangd')
    call add(g:coc_global_extensions, 'coc-clangd')
  endif

  if executable('tsserver')
    call add(g:coc_global_extensions, 'coc-tsserver')
    call add(g:coc_global_extensions, 'coc-prettier')
  endif

  if executable('javac')
    call add(g:coc_global_extensions, 'coc-java')
  endif

  if has('python3')
    call add(g:coc_global_extensions, 'coc-pyright')
  endif

  function! s:show_documentation()
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight
  augroup pluginCoc
    autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight')
  augroup end

  " Definition
  nmap     <silent> gd         <Plug>(coc-definition)
  nnoremap <silent> ge         :<C-u>CocCommand fzf-preview.CocReferences<CR>
  nnoremap <silent> gi         :<C-u>CocCommand fzf-preview.CocImplementations<CR>
  nnoremap <silent> <leader>cd :<C-u>call <SID>show_documentation()<CR>
  nnoremap <silent> <leader>ce :<C-u>CocCommand fzf-preview.CocDiagnostics<CR>
  nnoremap <silent> <leader>co :<C-u>CocCommand fzf-preview.CocOutline<CR>
  nmap     <silent> <leader>cn <Plug>(coc-rename)
  nmap     <silent> <leader>cr <Plug>(coc-refactor)

  " Action
  nmap <silent><nowait> <leader>ca <Plug>(coc-codeaction-cursor)
  nmap <silent><nowait> <leader>cr <Plug>(coc-codelens-action)

  " Error
  nmap [e <Plug>(coc-diagnostic-prev-error)
  nmap ]e <Plug>(coc-diagnostic-next-error)
  nmap [E <Plug>(coc-diagnostic-prev)
  nmap ]E <Plug>(coc-diagnostic-next)

  " Pop-up scrolling
  " nnoremap <expr><C-k> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  " nnoremap <expr><C-j> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  " inoremap <expr><C-k> coc#float#has_scroll() ? coc#float#scroll(1) : "\<Right>"
  " inoremap <expr><C-j> coc#float#has_scroll() ? coc#float#scroll(0) : "\<Left>"

  " More readable colors
  highlight link CocErrorSign DiffDelete
  highlight link CocWarningSign DiffChange
  highlight CocHighlightText ctermfg=255 guifg=#ffffff

  " TODO: FzfPreviewCoc does not show loading at the bottom, neither it is cancelabe.. This does it with caveats such as ESC not working and repeated lines
  " " Attach to CocLocations
  " augroup pluginCocLocation
  "   autocmd!
  "   let g:coc_enable_locationlist = 0
  "   autocmd User CocLocationsChange call s:coc_fzf_set_locations()
  " augroup END

  " function! s:coc_fzf_set_locations() abort
  "   " Todo ESC is not working
  "   let locations = deepcopy(get(g:, 'coc_jump_locations', ''))
  "   call setloclist(0, locations)
  "   FzfPreviewLocationList --add-fzf-arg=--prompt="Coc> "
  " endfunction

  " function! s:format_coc_diagnostic(item) abort
  "   if has_key(a:item, 'file')
  "     let filename = substitute(a:item.file, getcwd() . "/" , "", "")
  "     let text = substitute(a:item.message, "\n", " ", "g")
  "     let type = get({'Error': 'E', 'Warning': 'W', 'Information': 'I', 'Hint': 'H'}, a:item.severity, '')
  "     " let hl = get({'Error': 'cocerrorsign', 'Warning': 'cocwarningsign',
  "     "       \ 'Information': 'cocinfosign', 'Hint': 'cochintsign'}, a:item.severity, '')
  "     return { 'filename': filename, 'lnum': a:item.lnum, 'col': a:item.col, 'text': text, 'nr': a:item.code, 'type': type }
  "     " return coc_fzf#common_fzf_vim#green(printf("%s:%s:%s ",
  "     "       \ file, a:item.lnum, a:item.col), 'Comment') .
  "     "       \ coc_fzf#common_fzf_vim#red(a:item.severity, hl) . ' ' .
  "     "       \ msg
  "   endif
  "   return ''
  " endfunction

  " function! s:coc_fzf_set_diagnostics() abort
  "   let diagnostics = map(CocAction('diagnosticList'), 's:format_coc_diagnostic(v:val)')
  "   if !empty(diagnostics)
  "     " cgetexpr diagnostics
  "     call setqflist(diagnostics)
  "     FzfPreviewQuickFix --add-fzf-arg=--prompt="Diagnostics> "
  "   endif
  " endfunction

  """ VimInspector
  nmap <F2> <Plug>VimspectorLaunch
  nnoremap <silent> <leader><F2> :VimspectorReset<CR>
  nmap <F3> <Plug>VimspectorStop
  nmap <F4> <Plug>VimspectorRestart
  nmap <F5> <Plug>VimspectorContinue
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
      augroup pluginRacer
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
      augroup pluginTs
        autocmd!
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gd        :TSDef<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gD        :TSDefPreview<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> <leader>e :TSRename<CR>
      augroup END
    else
      let g:tsuquyomi_disable_quickfix = 1
      augroup pluginTs
        autocmd!
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gd        :TsuDefinition<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nnoremap <silent> gD        :TsuTypeDefinition<CR>
        autocmd FileType typescript,typescriptreact,typescript.tsx nmap     <buffer> <leader>e <Plug>(TsuquyomiRenameSymbolC)
      augroup END
    endif
  endif

  if exists('s:go')
    augroup pluginGoMap
      autocmd!
      autocmd FileType go nmap <buffer> <leader>e <Plug>(go-rename)
    augroup END
  endif

  """ Lint
  if has('nvim')

    call neomake#configure#automake('nrwi', 500)

    " Run `:Neomake clear` to clear the screen from Neomake
    let g:neomake_clear_maker = {}

    augroup pluginNeomakeHighlights
      autocmd!
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
