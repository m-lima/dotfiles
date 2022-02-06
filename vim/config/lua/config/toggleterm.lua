require('toggleterm').setup({
  size = 30,
})

-- TODO: Must check if lazy git is installed
local lazygit = require('toggleterm.terminal').Terminal:new({
  cmd = 'lazygit',
  direction = 'float',
  hidden = true,
})

local map = require('script.helper').map

map('n', '<leader>q',  ':ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qq', '<cmd>ToggleTermToggleAll<CR>')
map('n', '<leader>qn', ':ToggleTerm direction=horizontal<CR>')
map('n', '<leader>qf', '<cmd>ToggleTerm direction=float<CR>')
map('n', '<leader>qg', '<cmd>lua require("config.toggleterm").lazygit:toggle()<CR>')
map('t', '<C-q>',  '<cmd>ToggleTerm<CR>')

return {
  lazygit = lazygit,
}
