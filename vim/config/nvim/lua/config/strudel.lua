local map = require('util').map

require('strudel').setup({
  update_on_save = true,
})

map('n', '<leader><leader>st', require('strudel').toggle)
map('n', '<leader><leader>su', require('strudel').update)
