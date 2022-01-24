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
                                       "  - lualina.nvim
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

" Util
Plug 'nvim-telescope/telescope.nvim' " TODO: Configure
Plug 'kyazdani42/nvim-tree.lua' " TODO: Configure

" LSP
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " TODO: Configure
Plug 'neovim/nvim-lspconfig' " TODO: Configure

call plug#end()

" To check
" Plug 'hrsh7th/nvim-cmp' " TODO: Configure
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
" Plug 'hrsh7th/cmp-cmdline'
" Plug 'rmagatti/auto-session'
" vim-rooter does not like nvim-tree, apparently
" Plug 'ygm2/rooter.nvim'
" Plug 'ahmedkhalf/project.nvim'

lua require('config.nvim-treesitter')
lua require('config.nvim-tree')
lua require('config.lualine')
" lua require('config.nvim-lspconfig')

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
