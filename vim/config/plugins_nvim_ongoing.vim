""""""""""""""""""""
" Plugins install
""""""""""""""""""""

call plug#begin()

""" Dependencies
Plug 'tpope/vim-repeat'                " Dependency for vim-scripts/ReplaceWithRegister
Plug 'nvim-lua/plenary.nvim'           " Dependency for:
                                       "  - telescope.nvim
                                       "  - gitsigns
Plug 'kyazdani42/nvim-web-devicons'    " Dependency for:
                                       "  - telescope.nvim
                                       "  - nvim-tree.lua
                                       "  - lualine.nvim
Plug 'arkav/lualine-lsp-progress'      " Depency for:
                                       "  - lualine.nvim

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'numToStr/Comment.nvim'           " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'nvim-treesitter/nvim-treesitter-textobjects' " TODO: Completely not configured

" Rice
Plug 'nvim-lualine/lualine.nvim' " TODO: Double check

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" Navigation
Plug 'nvim-telescope/telescope.nvim' " TODO: Configure
Plug 'kyazdani42/nvim-tree.lua' " TODO: Configure
Plug 'ahmedkhalf/project.nvim' " TODO: Double check

" Telescope extensions
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" LSP
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " TODO: Configure
Plug 'neovim/nvim-lspconfig' " TODO: Configure
Plug 'williamboman/nvim-lsp-installer' " TODO: Configure

" Completion
Plug 'hrsh7th/nvim-cmp' " TODO: Configure
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Misc
Plug 'unblevable/quick-scope'        " Highlight on `f`
Plug 'aserebryakov/vim-todo-lists'   " TODO md file helper
Plug 'skanehira/vsession'            " Save/load sessions " TODO: Configure. I think now it keeps saving the session

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

lua <<EOF
require('config.cmp')
require('config.comment')
require('config.fugitive')
require('config.gitsigns')
require('config.lspconfig')
require('config.lualine')
require('config.nvim-lsp-installer')
require('config.nvim-tree')
require('config.nvim-treesitter')
require('config.project')
require('config.quick-scope')
require('config.telescope')
require('config.vsession')
EOF

""""""""""""""""""""
" Notes
""""""""""""""""""""

""" Trash
" Plug 'nvim-lua/lsp-status.nvim'        " Depency for:
"                                        "  - lualine.nvim
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }
" Plug 'fannheyward/telescope-coc.nvim' " Telescope coc

""" To check
" Great reference: https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
"
"" Completion
" "" Raw
" Raw with omni (lua vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc'))
"   Check `:h ins-completion`
" mucomplete
" "" Plugin
" Plug 'hrsh7th/nvim-cmp' " TODO: Configure
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
" Plug 'hrsh7th/cmp-cmdline'
"
"" Session
" Plug 'skanehira/vsession'
" Plug 'rmagatti/auto-session' " Session management
"
"" Rooter
" Plug 'ygm2/rooter.nvim' " Rooter
" Plug 'ahmedkhalf/project.nvim' " Rooter
" vim-rooter does not like nvim-tree, apparently
" With CoC: https://github.com/iamcco/coc-project
"
"" LSP
" Plug 'mfussenegger/nvim-dap' " Debugger
" Plug 'simrat39/rust-tools.nvim' " Extras for rust-analyzer " TODO: Configure
" Plug 'glepnir/lspsaga.nvim' " Extra UI functionilty for LSP
" "" Rust
" https://github.com/Saecki/crates.nvim
"
"" Util
" Github integration to jump to PRs?

""" Current main gripes
" Telescope: buffer ordering (sometimes the current buffer is selected, preferably, the # should be selected)
" Lsp: codelens is called at the bottom (maybe custom 'nvim-lua/popup.nvim')
" Telescope: start a search from Ex
" Telescope: change layout size based on results
" !! Rooter: Sooooo finnicky!
" Lualine: status spinner not working
" Lsp: rust-analyzer doesn't respect cargo.toml on parent directory
" Lsp: rust-analyzer complains that it hasn't completed (maybe because of autocmd)
" NvimTree: sometimes it breaks with CWD. Not sure how to replicate
" NvimTree: problem when deleting an open buffer
" NvimTree: keeps multiple lines selected when open and update_cwd
" Telesope: CocOutline
" Lsp: Hightlight usages is wonky for some languages (highlights too much)

""" Missing from before
" Telescope: recent files when opening project (maybe 'nvim-telescope/telescope-frecency.nvim')
" Telescope: equivalent for '/'
" Telescope: launch TODO
" Lsp: when typing in parameters, the documentation or param list should appear
" Lsp: Format on save
" Lsp: Per-project configuration (e.g. clippy vs check)

""" Wishes
" Write a plugin to simulate `CMD + UP`
" Write a plugin for session management
" Write an extension to `completion` that searches within path selected on nvimtree
" Write a plugin for copy + comment
