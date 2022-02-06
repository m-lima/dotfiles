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

return {
  toggleterm = toggleterm,
}
