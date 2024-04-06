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
        symbols = {
          error = ' ',
          warn = ' ',
          info = ' ',
          hint = ' ',
        },
      },
      require('config.lualine.components.git-status'),
    },
    lualine_c = {
      {
        components.filename,
        path = 1,
        symbols = {
          modified = ' ',
          readonly = ' ',
        },
      },
    },
    lualine_x = {
      require('config.lualine.components.lsp-status'),
      function()
        return vim.bo.filetype == 'scala' and vim.g.metals_status or ''
      end,
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
          readonly = ' ',
        },
      },
    },
    lualine_x = {},
  },
})
