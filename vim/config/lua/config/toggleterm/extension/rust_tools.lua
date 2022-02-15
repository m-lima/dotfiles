local utils = require("rust-tools.utils.utils")

local M = {}

function M.execute_command(command, args, cwd)
  local cmd = utils.make_command_from_args(command, args)
  cmd = 'echo "' .. cmd .. '" && ' .. cmd
  return require('toggleterm.terminal').Terminal:new({
    dir = cwd,
    cmd = cmd,
    close_on_exit = false,
    direction = 'float',
    on_open = function(term)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true), "", true)
      vim.api.nvim_buf_set_keymap(term.bufnr, '', '<C-q>', '<cmd>close<CR>', { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(term.bufnr, '', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  }):toggle()
end

return M
