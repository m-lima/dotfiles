""""""""""""""""""""
" Plugins install
""""""""""""""""""""

call plug#begin()

""" Dependencies
Plug 'tpope/vim-repeat'                " Dependency for:
                                       "  - vim-scripts/ReplaceWithRegister
Plug 'nvim-lua/plenary.nvim'           " Dependency for:
                                       "  - telescope
                                       "  - neo-tree
                                       "  - gitsigns
Plug 'kyazdani42/nvim-web-devicons'    " Dependency for:
                                       "  - telescope
                                       "  - neo-tree
                                       "  - lualine
Plug 'arkav/lualine-lsp-progress'      " Depency for:
                                       "  - lualine.nvim
Plug 'MunifTanjim/nui.nvim'            " Dependency for:
                                       "  - neo-tree

" Verbs
Plug 'tpope/vim-surround'              " s
Plug 'numToStr/Comment.nvim'           " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'nvim-treesitter/nvim-treesitter-textobjects' " TODO: Completely not configured

" Rice
Plug 'nvim-lualine/lualine.nvim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" Navigation
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v2.x' }
Plug 'ahmedkhalf/project.nvim'

" Telescope extensions
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope-dap.nvim'

" LSP
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

" Debugging
Plug 'mfussenegger/nvim-dap' " TODO: Lots!
Plug 'rcarriga/nvim-dap-ui'

" Completion
Plug 'hrsh7th/nvim-cmp' " TODO: Configure
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Misc
Plug 'unblevable/quick-scope'        " Highlight on `f`
Plug 'aserebryakov/vim-todo-lists'   " TODO md file helper
Plug 'skanehira/vsession'            " Save/load sessions TODO: Configure. I think now it keeps saving the session
Plug 'akinsho/toggleterm.nvim'       " More usable terminal
Plug 'mbbill/undotree'               " A local changes tracker TODO: configure (colors)

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

lua <<EOF
require('config.cmp')
require('config.comment')
require('config.dap')
require('config.fugitive')
require('config.gitsigns')
require('config.lsp-installer')
require('config.lspconfig')
require('config.lualine')
require('config.neo-tree')
require('config.nvim-treesitter')
require('config.project')
require('config.quick-scope')
require('config.telescope')
require('config.toggleterm')
require('config.undotree')
require('config.vsession')

-- Personal
require('plugin.buffer_stack')
require('plugin.dupe_comment')
require('plugin.breadcrumbs')
require('script.output')
EOF

""""""""""""""""""""
" Notes
""""""""""""""""""""

""" To check
" Great reference: https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
" Plugin building example: https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua
"
"" Completion
" "" Raw
" Raw with omni (lua vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc'))
"   Check `:h ins-completion`
" mucomplete
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

""" TO FIX
" TELESCOPE: change layout size based on results
" LUALINE: status spinner not working
" TELESOPE: CocOutline
" Auto-close of braces does not follow the format
" LSP: Really need to know when the async process is running (some kind of status or spineer)
" Telescope opening a file while focused on nvimtree, does not open on main pane
"
"" Missing from before
" TELESCOPE: recent files when opening project (maybe 'nvim-telescope/telescope-frecency.nvim')
" TELESCOPE: launch TODO
" LSP: when typing in parameters, the documentation or param list should appear
" LSP: Code outline. There are symbols, but the outline shows hierarchy better (maybe custom plugin?)
" LSP: Show that the request is running in the background (get references e.g.)
"
"" Wishes
" Write a plugin for session management
  " Sessions per branch if for example no name is provided
    " Check for deleted branches to clean session files
  " Telescope integration
  " Don't autosave session, but have a `:W` or something like that
" Write an extension to `completion` that searches within path selected on nvimtree
" Warn if overwriting a mark
" Telescope ougoing and incoming calls
" Telescope remove repeats
" Open file from toggleterm
" Open file from lazygit

""" Done
" NVIMTREE: keeps multiple lines selected when open and update_cwd
" TELESCOPE: When on buffers and start typing, cursor should jump to the bottom (or the bottom should have the previous buffer already)
" Write a plugin to simulate `CMD + UP`
" Autoformatting not always working
" Show marks in the gutter
" Syntax highlight of inlay hints (bg on cursor line is not respected.. Worth checking what diagnostics do for this)
" DEBUG: Codelens compatible with vimspector
" LSP: Per-project configuration (e.g. clippy vs check)
" LSP: Format on save
" LUALINE: Lockdown the theme
" C-O that skips jumps within the same file
" LUALINE: Modified file color should not be hardcoded. Maybe derive from git modified color
" Match gutter icons with statusline diagnostics
" TELESCOPE: equivalent for '/'
" TELESCOPE: start a search from Ex
" TELESCOPE: grep-string breks when searching for anything more complex than a single word
" LSP: RUST: When opening a cargo file, the root of the project breaks (i,e, a cargo workspace) [Removed TOML lsp]
" Wait for rust-analyzer to be ready
" LSP: rust-analyzer complains that it hasn't completed (maybe because of autocmd)
" LSP: rust-analyzer doesn't respect cargo.toml on parent directory
" !! ROOTER: Sooooo finnicky!
" LSP: codelens is called at the bottom (maybe custom 'nvim-lua/popup.nvim')
" Selection on grayalt should not override foreground
" Color of inlay errors
" Change grayalt to highlight matches on completion popup (maybe also make telescope matches more visible as well)

"""Won't do
" LSP: Hightlight usages is wonky for some languages (highlights too much)
" NVIMTREE: sometimes it breaks with CWD. Not sure how to replicate
" NVIMTREE: problem when deleting an open buffer
" NVIMTREE: polutes the jumplist (reproducible by opening two files from cmdline)
