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
    buffers = {
      sort_lastused = true,
      sort_mru = true,
    },
  },
})

telescope.load_extension('fzf')
telescope.load_extension('projects')

local map = require('script.helper').map

-- General
map('n', '<leader><leader><leader>', '<cmd>Telescope resume<CR>')

-- Search
map('n', '<leader>*', '<cmd>Telescope grep_string<CR>')
map('n', '<leader>8', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
map('n', '<leader>/', '<cmd>Telescope live_grep<CR>')
map('n', '?',         ':<C-u>Telescope grep_string disable_coordinates=true search=', { silent = false })

-- Navigation
map('n', '<leader>p',     '<cmd>Telescope find_files<CR>')
map('n', '<leader>P',     '<cmd>Telescope find_files no_ignore=true<CR>')
map('n', '<leader>o',     '<cmd>Telescope oldfiles<CR>')
map('n', '<leader>b',     '<cmd>Telescope buffers<CR>')
map('n', '<leader><c-o>', '<cmd>Telescope jumplist<CR>')
map('n', '<leader>m',     '<cmd>Telescope marks<CR>')

---- Projects
map('n', '<leader><leader>p', '<cmd>Telescope projects<CR>')

---- LSP
map('n', 'gd',        '<cmd>Telescope lsp_definitions<CR>')
map('n', 'ge',        '<cmd>Telescope lsp_references<CR>')
map('n', 'gi',        '<cmd>Telescope lsp_implementations<CR>')
map('n', 'gI',        '<cmd>Telescope lsp_type_definitions<CR>')
map('n', '<leader>a', '<cmd>Telescope lsp_code_actions<CR>')
map('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<CR>')
map('n', '<leader>S', '<cmd>Telescope lsp_workspace_symbols<CR>')
map('n', '<leader>e', '<cmd>Telescope diagnostics<CR>')