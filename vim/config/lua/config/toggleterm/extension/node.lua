return require('toggleterm.terminal').Terminal:new({
  cmd = 'node',
  direction = 'float',
  hidden = true,
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<C-q>', '<cmd>close<CR>', { noremap = true, silent = true })
  end,
})
