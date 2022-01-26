require('lualine').setup({
  extensions = { 'quickfix', 'nvim-tree' },
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '╲', right = '╱' },
  },
  sections = {
    -- TODO: add a buffer counter
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
        'filename',
        path = 1,
        -- TODO: Make it more obvious when modified `if vim.bo.modified`
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
    lualine_y = {},
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
