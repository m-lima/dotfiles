local components = require('config.lualine.components')

local toggleterm = {}

toggleterm.sections = {
  lualine_a = {
    components.paste,
    'mode'
  },
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = { components.changed_buffers },
  lualine_z = { components.toggleterm },
}
toggleterm.filetypes = { 'toggleterm' }

local neotree = {}
neotree.sections = {
  lualine_a = { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end },
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = {},
  lualine_z = {},
}
neotree.filetypes = { 'neo-tree' }

return {
  toggleterm = toggleterm,
  neotree = neotree,
}
