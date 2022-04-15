require('toggleterm').setup({
  size = function(term)
    if term.direction == 'horizontal' then
      return vim.o.lines * 0.3
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.3
    end
  end,
  shade_terminals = false,
})

local map = require('script.helper').map

map('n', '<C-q>',       '<cmd>1ToggleTerm direction=float<CR>')
map('t', '<C-q>',       '<cmd>ToggleTerm<CR>')
map('n', '<leader>qs',  '<cmd>exec v:count1 "ToggleTerm direction=horizontal"<CR>')
map('n', '<leader>qv',  '<cmd>exec v:count1 "ToggleTerm direction=vertical"<CR>')
map('n', '<leader>qf',  '<cmd>exec v:count1 "ToggleTerm direction=float"<CR>')
map('n', '<leader>qq',  '<cmd>ToggleTermToggleAll<CR>')
map('n', '<leader>qg',  '<cmd>lua require("config.toggleterm.extension").lazygit():toggle()<CR>')
map('n', '<leader>qe',  '<cmd>9ToggleTerm<CR>')

-- REPL
map('n', '<leader>qrr', '<cmd>lua require("config.toggleterm.extension").evcxr():toggle()<CR>')
map('n', '<leader>qrn', '<cmd>lua require("config.toggleterm.extension").node():toggle()<CR>')
map('n', '<leader>qrp', '<cmd>lua require("config.toggleterm.extension").python():toggle()<CR>')
map('n', '<leader>qrl', '<cmd>lua require("config.toggleterm.extension").luajit():toggle()<CR>')
