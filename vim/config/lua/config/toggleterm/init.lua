require('toggleterm').setup({
  size = 30,
  shade_terminals = false,
})

local map = require('script.helper').map

map('n', '<C-q>',       '<cmd>0ToggleTerm direction=float<CR>')
map('t', '<C-q>',       '<cmd>0ToggleTerm<CR>')
map('n', '<leader>q',   '<cmd>0ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qn',  '<cmd>0ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qf',  '<cmd>0ToggleTerm direction=float<CR>')
map('n', '<leader>qq',  '<cmd>ToggleTermToggleAll<CR>')
map('n', '<leader>qg',  '<cmd>lua require("config.toggleterm.extension").lazygit():toggle()<CR>')
map('n', '<leader>qe',  '<cmd>9ToggleTerm<CR>')

-- REPL
map('n', '<leader>qrr', '<cmd>lua require("config.toggleterm.extension").evcxr():toggle()<CR>')
map('n', '<leader>qrn', '<cmd>lua require("config.toggleterm.extension").node():toggle()<CR>')
map('n', '<leader>qrp', '<cmd>lua require("config.toggleterm.extension").python():toggle()<CR>')
map('n', '<leader>qrl', '<cmd>lua require("config.toggleterm.extension").luajit():toggle()<CR>')
