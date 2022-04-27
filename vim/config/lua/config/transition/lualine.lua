local components = require('config.lualine.components')

require('lualine').setup({
  extensions = { 'quickfix', 'nvim-tree' },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
    globalstatus = true,
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
      'g:coc_status',
    },
    lualine_x = { 'filetype' },
    lualine_y = { components.changed_buffers },
    lualine_z = { components.location },
  },
  inactive_sections = {
    lualine_c = {
      {
        'filename',
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
