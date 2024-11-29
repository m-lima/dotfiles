vim.g.lightspeed_no_default_keymaps = true

local map = require('util').map

map({ 'n', 'x' }, 's',  '<Plug>Lightspeed_s')
map({ 'n', 'x' }, 'S',  '<Plug>Lightspeed_S')
map('o',          'z',  '<Plug>Lightspeed_s')
map('o',          'Z',  '<Plug>Lightspeed_S')
map('o',          'x',  '<Plug>Lightspeed_x')
map('o',          'X',  '<Plug>Lightspeed_X')
map('n',          'gs', '<Plug>Lightspeed_gs')
map('n',          'gS', '<Plug>Lightspeed_gS')
