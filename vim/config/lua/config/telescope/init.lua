require('telescope').setup({
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      vertical = {
        width = 0.9,
        height = 0.95,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
    lsp_code_actions = {
      theme = 'dropdown',
    },
  },
})

require('telescope').load_extension('fzf')

-- General
vim.api.nvim_set_keymap('n', '<leader><leader><leader>', ':Telescope resume<CR>', { noremap = true, silent = true })

-- Search
vim.api.nvim_set_keymap('n', '<leader><leader>8', ':Telescope grep_string<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '?', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>p', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P', ':Telescope find_files no_ignore=true<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>o', ':Telescope oldfiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><c-o>', ':Telescope jumplist<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m', ':Telescope marks<CR>', { noremap = true, silent = true })

-- LSP
vim.api.nvim_set_keymap('n', 'gd', ':Telescope lsp_definitions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ge', ':Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi', ':Telescope lsp_implementations<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', ':Telescope lsp_code_actions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>S', ':Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':Telescope diagnostics<CR>', { noremap = true, silent = true })
