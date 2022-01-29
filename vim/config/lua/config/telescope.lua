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
