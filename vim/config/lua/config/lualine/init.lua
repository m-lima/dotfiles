local components = require('config.lualine.components')
local extensions = require('config.lualine.extensions')

require('lualine').setup({
  extensions = { 'quickfix', 'nvim-tree', extensions.toggleterm },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
  },
  sections = {
    lualine_a = {
      components.paste,
      'mode'
    },
    lualine_b = {
      'diff',
      {
        'diagnostics',
        sources = { 'nvim_lsp' },
        diagnostics_color = {
          error = {
            fg = '#df5f5f',
          },
        },
      },
    },
    lualine_c = {
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
        display_components = {{ 'title', 'percentage', 'message' }},
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