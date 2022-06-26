local components = require('config.lualine.components')
local extensions = require('config.lualine.extensions')
local themes = require('config.lualine.themes')

require('lualine').setup({
  extensions = { 'quickfix', extensions.toggleterm, extensions.neotree },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
    theme = themes.grayalt,
    globalstatus = false,
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
      require('config.lualine.components.git-status'),
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
        display_components = { { 'title', 'percentage', 'message' } },
      },
    },
    lualine_x = {
      require('config.lualine.components.lsp-status'),
      'filetype',
      components.active_lsp,
    },
    lualine_y = { components.changed_buffers },
    lualine_z = { components.location },
  },
  inactive_sections = {
    lualine_c = {
      {
        '%F',
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
