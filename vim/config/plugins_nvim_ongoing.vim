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
Plug 'kana/vim-textobj-user'           " Dependency for text objects
Plug 'tpope/vim-repeat'                " Depenency for vim-scripts/ReplaceWithRegister
Plug 'nvim-lua/plenary.nvim'           " Dependency for:
                                       "  - telescope.nvim
Plug 'kyazdani42/nvim-web-devicons'    " Dependency for:
                                       "  - telescope.nvim
                                       "  - nvim-tree.lua
                                       "  - lualine.nvim
Plug 'arkav/lualine-lsp-progress'      " Depency for:
                                       "  - lualine.nvim

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

" Rice
Plug 'nvim-lualine/lualine.nvim' " TODO: Double check

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Navigation
Plug 'nvim-telescope/telescope.nvim' " TODO: Configure
Plug 'kyazdani42/nvim-tree.lua' " TODO: Configure

" Telescope extensions
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" LSP
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " TODO: Configure
Plug 'neovim/nvim-lspconfig' " TODO: Configure
Plug 'williamboman/nvim-lsp-installer' " TODO: Configure

" Misc
Plug 'unblevable/quick-scope'
Plug 'aserebryakov/vim-todo-lists'

" Trash
" Plug 'nvim-lua/lsp-status.nvim'        " Depency for:
"                                        "  - lualine.nvim
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }
" Plug 'fannheyward/telescope-coc.nvim' " Telescope coc

call plug#end()

" To check
" Plug 'hrsh7th/nvim-cmp' " TODO: Configure
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
" Plug 'hrsh7th/cmp-cmdline'
" Plug 'rmagatti/auto-session' " Session management
" vim-rooter does not like nvim-tree, apparently
" Plug 'ygm2/rooter.nvim' " Rooter
" Plug 'ahmedkhalf/project.nvim' " Rooter
" Plug 'mfussenegger/nvim-dap' " Debugger
" Plug 'simrat39/rust-tools.nvim' " Extras for rust-analyzer " TODO: Configure
" Plug 'glepnir/lspsaga.nvim' " Extra UI functionilty for LSP

lua require('config.nvim-treesitter')
lua require('config.nvim-tree')
lua require('config.lualine')
lua require('config.telescope')
" lua require('config.lsp-status')
lua require('config.nvim-lspconfig')
lua require('config.nvim-lsp-installer')
" lua require('rust-tools').setup({})

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

""" Quick-scope
let g:qs_highlight_on_keys = ['f', 'F']
highlight link QuickScopePrimary Visual
highlight link QuickScopeSecondary Search


""" Current main gripes
" Telescope: buffer ordering (sometimes the current buffer is selected, preferably, the # should be selected)
" Lualine: modified file is not easy to notice
" Lsp: codelens is called at the bottom (maybe custom 'nvim-lua/popup.nvim')
" Lsp: when typing in parameters, the documentation or param list should appear
" Telescope: start a search from Ex
" Telescope: change layout depending on screen size (maybe use autocmd)
" Telescope: change layout size based on results
" Lualine: status spinner not working
" Lsp: highlight usages
" Lsp: rust-analyzer doesn't respect cargo.toml on parent directory
" Lsp: rust-analyzer complains that it hasn't completed (maybe because of autocmd)

""" Missing from before
" Telescope: recent files when opening project (maybe 'nvim-telescope/telescope-frecency.nvim')
" Telescope: equivalent for '/'

""" Wishes
" Lualine: Reduce the 'MODE' to a small bar
