vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_respect_buf_cwd = 1

require('nvim-tree').setup({
  update_cwd = true,
  diagnostics = {
    enable = true,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  view = {
    width = '33%',
  },
  git = {
    ignore = false,
  },
})

require('script.helper').map('n', '<leader>n', '<cmd>NvimTreeFindFileToggle<CR>')
