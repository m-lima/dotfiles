local M = {}

function M.map(mode, key, action, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.api.nvim_set_keymap(mode, key, action, opts)
end

M.hi = vim.highlight

return M
