local toggleterm = require('toggleterm')
local extension = require('config.toggleterm.extension')
local map = require('script.helper').map

toggleterm.setup({
  size = function(term)
    if term.direction == 'horizontal' then
      return vim.o.lines * 0.3
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.3
    end
  end,
  shade_terminals = false,
})

map('n', '<C-q>',      function() toggleterm.toggle(1, nil, nil, 'float') end)
map('t', '<C-q>',      function() toggleterm.toggle(0) end)
map('n', '<leader>qq', toggleterm.toggle_all)
map('n', '<leader>qg', function() extension.lazygit():toggle() end)
map('n', '<leader>qe', function() toggleterm.toggle(109) end)
map('n', '<leader>qs', function() toggleterm.toggle(1, nil, nil, 'horizontal') end)
map('n', '<leader>qv', function() toggleterm.toggle(1, nil, nil, 'vertical') end)
map('n', '<leader>qf', function() toggleterm.toggle(1, nil, nil, 'float') end)
map('n', '<leader><leader>qs', function() toggleterm.toggle(2, nil, nil, 'horizontal') end)
map('n', '<leader><leader>qv', function() toggleterm.toggle(2, nil, nil, 'vertical') end)
map('n', '<leader><leader>qf', function() toggleterm.toggle(2, nil, nil, 'float') end)
map('n', '<leader><leader><leader>qs', function() toggleterm.toggle(3, nil, nil, 'horizontal') end)
map('n', '<leader><leader><leader>qv', function() toggleterm.toggle(3, nil, nil, 'vertical') end)
map('n', '<leader><leader><leader>qf', function() toggleterm.toggle(3, nil, nil, 'float') end)

-- REPL
map('n', '<leader>qrr', function() extension.evcxr():toggle() end)
map('n', '<leader>qrn', function() extension.node():toggle() end)
map('n', '<leader>qrp', function() extension.python():toggle() end)
map('n', '<leader>qrl', function() extension.luajit():toggle() end)
