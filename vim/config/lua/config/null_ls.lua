local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
  },
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      local augroupnr = vim.api.nvim_create_augroup('none_ls_' .. client.name .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd(
        'BufWritePre',
        {
          desc = 'Format code',
          group = augroupnr,
          buffer = bufnr,
          callback = function() vim.lsp.buf.format() end,
        }
      )
    end
  end,
})
