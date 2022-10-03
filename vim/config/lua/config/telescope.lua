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
          preview_width = .5,
        },
      },
    },
    lsp_document_symbols = {
      sorting_strategy = 'ascending',
    },
    lsp_code_actions = {
      theme = 'dropdown',
    },
    buffers = {
      ignore_current_buffer = true,
      sort_lastused = true,
      sort_mru = true,
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    },
    ["dap"] = {
      require("telescope.themes").get_dropdown {}
    },
  }
})

telescope.load_extension('fzf')
telescope.load_extension('projects')
telescope.load_extension('ui-select')
telescope.load_extension('dap')

local builtin = require('telescope.builtin')

vim.api.nvim_create_user_command(
  'Rg',
  function(args)
    builtin.grep_string({ disable_coordinates = true, search = args.args })
  end,
  {
    desc = 'Search globally for strings',
    nargs = 1,
  }
)
vim.api.nvim_create_user_command(
  'Rgs',
  function(args)
    builtin.lsp_workspace_symbols({ query = args.args })
  end,
  {
    desc = 'Search globally for symbols',
    nargs = 1,
  }
)

local map = require('util').map

-- General
map('n', '<leader><leader><leader>', builtin.resume)

-- Search
map('n', '<leader>8', '"<cmd>Telescope current_buffer_fuzzy_find<CR>" . expand("<cword>") . "<Esc>"', { expr = true })
map('n', '<leader>*', function() builtin.grep_string({ disable_coordinates = true }) end)
map('n', '<leader>/', builtin.current_buffer_fuzzy_find)
map('n', '<leader>?', function() builtin.live_grep({ disable_coordinates = true }) end)
map('n', '?',         ':<C-u>Rg ', { silent = false })

-- Navigatio
map('n', '<leader>p',     builtin.find_files)
map('n', '<leader>P',     function() builtin.find_files({ no_ignore = true }) end)
map('n', '<leader>o',     builtin.oldfiles)
map('n', '<leader>b',     builtin.buffers)
map('n', '<leader><c-o>', builtin.jumplist)
map('n', '<leader>m',     builtin.marks)
map('n', '<leader>gt',    builtin.git_status)

---- Projects
map('n', '<leader><leader>p', telescope.extensions.projects.projects)

---- LSP
map('n', 'gd',        builtin.lsp_definitions)
map('n', 'gvd',       function() builtin.lsp_definitions({ jump_type = 'vsplit' }) end)
map('n', 'ge',        builtin.lsp_references)
map('n', 'gve',       function() builtin.lsp_references({ jump_type = 'vsplit' }) end)
map('n', 'gi',        builtin.lsp_implementations)
map('n', 'gvi',       function() builtin.lsp_implementations({ jump_type = 'vsplit' }) end)
map('n', 'gI',        builtin.lsp_type_definitions)
map('n', 'gvI',       function() builtin.lsp_type_definitions({ jump_type = 'vsplit' }) end)
map('n', '<leader>s', builtin.lsp_document_symbols)
map('n', '<leader>S', builtin.lsp_dynamic_workspace_symbols)
map('n', '<leader>e', builtin.diagnostics)
map('n', '<leader>E', function() builtin.diagnostics({ severity = 'error' }) end)
