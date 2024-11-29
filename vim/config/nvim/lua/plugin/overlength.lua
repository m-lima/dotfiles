local map = require('util').map

local M = {}

local default_config = {
  initial_width = 100,
  color = '#a00000',
  map = {
    toggle = '<leader>ww',
    increase = '<leader>we',
    decrease = '<leader>wq',
  },
}

local enable = function()
  vim.b.overlength_visible = true

  vim.cmd([[match mlima_overlength /\%]] .. (vim.b.overlength_width + 1) .. [[v.\+/]])
  vim.notify('Overlength set to ' .. vim.b.overlength_width, vim.log.levels.INFO)
end

local disable = function()
  vim.b.overlength_visible = false

  vim.cmd [[match none]]
  vim.notify('Overlength disabled', vim.log.levels.INFO)
end

M.toggle = function()
  if vim.b.overlength_visible then
    disable()
  else
    if not vim.b.overlength_width then
      vim.b.overlength_width = default_config.initial_width
    end

    enable()
  end
end

M.shift = function(amount)
  vim.b.overlength_width = (vim.b.overlength_width or default_config.initial_width) + amount
  enable()
end

vim.api.nvim_set_hl(0, 'mlima_overlength', { bg = default_config.color })
map('n', default_config.map.toggle, M.toggle)
map('n', default_config.map.increase, function() M.shift(10) end)
map('n', default_config.map.decrease, function() M.shift(-10) end)

return M
