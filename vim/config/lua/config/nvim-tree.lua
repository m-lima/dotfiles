vim.g.nvim_tree_respect_buf_cwd = 1

require('nvim-tree').setup({
  hijack_cursor = true,
  auto_close = true,
  update_cwd = true,
  diagnostics = {
    enable = true,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  view = {
    width = '30%',
    hide_root_folder = true,
  },
  git = {
    ignore = false,
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
})

require('script.helper').map('n', '<leader>n', '<cmd>NvimTreeFindFileToggle<CR>')
