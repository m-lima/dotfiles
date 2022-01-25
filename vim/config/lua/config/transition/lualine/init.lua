require('lualine').setup({
  extensions = { 'quickfix', 'nvim-tree' },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
  },
  sections = {
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
        'filename',
        path = 1,
        -- TODO: Make it more obvious when modified `if vim.bo.modified`
        symbols = {
          modified = ' ',
          readonly = ' ',
        },
      },
      'g:coc_status',
    },
    lualine_x = {'filetype'},
  },
  inactive_sections = {
    lualine_c = {
      {
        'filename',
        path = 1,
        -- TODO: Make it more obvious when modified `if vim.bo.modified`
        symbols = {
          modified = ' ',
          readonly = ' ',
        },
      },
    },
  },
})

