local telescope = require('telescope')

telescope.setup({
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

telescope.load_extension('fzf')
telescope.load_extension('projects')
