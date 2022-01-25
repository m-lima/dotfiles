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
Plug 'nvim-lualine/lualine.nvim' " TODO: Double check

""" Util
Plug 'kyazdani42/nvim-tree.lua' " TODO: Configure, LazyLoad
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter' " Broke nvim-tree
Plug 'aserebryakov/vim-todo-lists'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'unblevable/quick-scope'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " TODO: Configure
" Plug 'ygm2/rooter.nvim' " TODO: Kinda broken
" Add session manaher

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

""" Languages

" QML has no LSP
Plug 'peterhoeg/vim-qml', { 'for': 'qml' }

" LSP
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Debugging
Plug 'puremourning/vimspector', { 'on': [ '<Plug>VimspectorLaunch', '<Plug>VimspectorToggleBreakpoint' ] }

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""
lua <<EOF
require('config.gitgutter')
require('config.transition.lualine')
require('config.nvim-tree')
require('config.nvim-treesitter')
require('config.quick-scope')
EOF

""""""""""""""""""""
" Plugins mapping
""""""""""""""""""""

lua <<EOF
require('mapping.git')
require('mapping.rice')
EOF

""""""""""""""""""""
" Old config
""""""""""""""""""""

""" Vim-rooter
let g:rooter_patterns = ['.vim/', '.git/', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'build.gradle', 'CMakeLists.txt']

""" Fzf-Preview
" TODO: Use Delta
" TODO: More git actions
" TODO: Highlight matched text in line and in preview
" TODO: Show processing, e.g. coc-references, in the statusline
" TODO: Allow calling the preview without having to rewrite it (just reopen)
" TODO: Diagnostics preview currently broken (fork/exec /bin/zsh: invalid argument)
nnoremap <silent> <leader>p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
nnoremap <silent> <leader>P     :<C-u>CocCommand fzf-preview.DirectoryFiles<CR>
nnoremap <silent> <leader>b     :<C-u>CocCommand fzf-preview.Buffers<CR>
nnoremap <silent> <leader>B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
nnoremap <silent> <leader>o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>

nnoremap <silent> <leader>mgs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
nnoremap <silent> <leader>mga    :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> <leader>mg;    :<C-u>CocCommand fzf-preview.Changes<CR>

nnoremap <silent> <leader>/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
nnoremap <silent> <leader>8     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap          <leader>*     :<C-u>Rg <C-r>=expand('<cword>')<CR><CR>
nnoremap          ?              :<C-u>Rg<Space>

nnoremap <silent> <leader><C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
nnoremap <silent> <leader>mt     :<C-u>CocCommand fzf-preview.BufferTags<CR>
nnoremap <silent> <leader>mq     :<C-u>CocCommand fzf-preview.QuickFix<CR>
nnoremap <silent> <leader>ml     :<C-u>CocCommand fzf-preview.LocationList<CR>

command! -bang -nargs=* Rg CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--prompt="Rg> " <q-args>

let g:fzf_preview_use_dev_icons = 1

""" Quick-scope
let g:qs_highlight_on_keys = ['f', 'F']
highlight link QuickScopePrimary Visual
highlight link QuickScopeSecondary Search

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
nmap     <silent> gd                <Plug>(coc-definition)
nnoremap <silent> ge                :<C-u>CocCommand fzf-preview.CocReferences<CR>
nnoremap <silent> gi                :<C-u>CocCommand fzf-preview.CocImplementations<CR>
nnoremap <silent> <leader>d        :<C-u>call <SID>show_documentation()<CR>
nnoremap <silent> <leader>e        :<C-u>CocCommand fzf-preview.CocDiagnostics<CR>
nnoremap <silent> <leader>s        :<C-u>CocCommand fzf-preview.CocOutline<CR>
nmap     <silent> <leader><leader>r <Plug>(coc-rename)

" Action
nmap <silent><nowait> <leader>a <Plug>(coc-codeaction-cursor)
nmap <silent><nowait> <leader>r <Plug>(coc-codelens-action)

" Error
nmap [e <Plug>(coc-diagnostic-prev)
nmap ]e <Plug>(coc-diagnostic-next)

" More readable colors
highlight link CocErrorSign DiffDelete
highlight link CocWarningSign DiffChange
highlight CocHighlightText ctermfg=255 guifg=#ffffff

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
