local components = require('config.lualine.components')
local extensions = require('config.lualine.extensions')
local themes = require('config.lualine.themes')

require('lualine').setup({
  extensions = { 'quickfix', 'nvim-tree', extensions.toggleterm },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
    theme = themes.grayalt,
  },
  sections = {
    lualine_a = {
      components.paste,
      'mode'
    },
    lualine_b = {
      {
        'diagnostics',
        sources = { 'nvim_lsp' },
      },
    },
    lualine_c = {
      require('config.lualine.components.git-status'),
      {
        components.filename,
        path = 1,
        symbols = {
          modified = ' ',
          readonly = ' ',
        },
      },
      {
        'lsp_progress',
        display_components = { { 'title', 'percentage', 'message' } },
      },
    },
    lualine_x = { 'filetype' },
    lualine_y = { components.changed_buffers },
    lualine_z = { components.location },
  },
  inactive_sections = {
    lualine_c = {
      {
        components.filename,
        path = 1,
        symbols = {
          modified = ' ',
          readonly = ' ',
        },
      },
    },
    lualine_x = {},
  },
})
