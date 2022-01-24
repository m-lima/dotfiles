vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_respect_buf_cwd = 1

require('nvim-tree').setup({
  -- TODO: What does this do?
  update_cwd = true,
  diagnostics = {
    enable = true,
  },
  -- TODO: Disabled because of new workflow of always hidding
  -- TODO: Write a plugin to simulate `CMD + UP`
  update_focused_file = {
    enable = true,
    -- TODO: Fix this. It keeps more than one line selected
    update_cwd = true,
  },
  view = {
    width = '33%',
  },
})

vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
