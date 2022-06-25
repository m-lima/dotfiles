local config = {
  max_height = 40,
  max_width = 100,

  hint_enable = false,
  hint_prefix = '',

  toggle_key = '<C-x>',
}

return {
  on_attach = function(bufnr)
    vim.notify('attached signature')
    require('lsp_signature').on_attach(config, bufnr)
  end
}
