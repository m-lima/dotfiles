require('toggleterm').setup({
  size = 30,
})

local map = require('script.helper').map

map('n', '<C-q>',       '<cmd>ToggleTerm direction=float<CR>')
map('t', '<C-q>',       '<cmd>ToggleTerm<CR>')
map('n', '<leader>q',   ':ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qq',  '<cmd>ToggleTermToggleAll<CR>')
map('n', '<leader>qn',  ':ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qf',  '<cmd>ToggleTerm direction=float<CR>')
map('n', '<leader>qg',  '<cmd>lua require("config.toggleterm.extension.lazygit"):toggle()<CR>')

-- REPL
map('n', '<leader>qrr', '<cmd>lua require("config.toggleterm.extension.evcxr"):toggle()<CR>')
map('n', '<leader>qrn', '<cmd>lua require("config.toggleterm.extension.node"):toggle()<CR>')
map('n', '<leader>qrp', '<cmd>lua require("config.toggleterm.extension.python"):toggle()<CR>')
