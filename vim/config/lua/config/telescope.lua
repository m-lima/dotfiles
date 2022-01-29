local telescope = require('telescope')

telescope.setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      horizontal = {
        width = 0.9,
        height = 0.95,
      },
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
    current_buffer_fuzzy_find = {
      layout_strategy = 'horizontal',
      sorting_strategy = 'ascending',
      layout_config = {
        horizontal = {
          preview_width = .75,
        },
      },
    },
    lsp_code_actions = {
      theme = 'dropdown',
    },
  },
})

telescope.load_extension('fzf')
telescope.load_extension('projects')

-- General
vim.api.nvim_set_keymap('n', '<leader><leader><leader>', '<cmd>Telescope resume<CR>', { noremap = true, silent = true })

-- Search
vim.api.nvim_set_keymap('n', '<leader>*', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>8', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>/', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '?',         ':<C-u>Telescope grep_string disable_coordinates=true search=', { noremap = true })

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>p',     '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P',     '<cmd>Telescope find_files no_ignore=true<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>o',     '<cmd>Telescope oldfiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b',     '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><c-o>', '<cmd>Telescope jumplist<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m',     '<cmd>Telescope marks<CR>', { noremap = true, silent = true })

---- Projects
vim.api.nvim_set_keymap('n', '<leader><leader>p', '<cmd>Telescope projects<CR>', { noremap = true, silent = true })

---- LSP
vim.api.nvim_set_keymap('n', 'gd',        '<cmd>Telescope lsp_definitions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ge',        '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi',        '<cmd>Telescope lsp_implementations<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi',        '<cmd>Telescope lsp_type_definitions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>Telescope lsp_code_actions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>S', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
