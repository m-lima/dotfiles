local map = require('util').map

local inline = true

local flip_multiline = function()
  inline = not inline
  return vim.diagnostic.config({
    virtual_lines = not inline,
    virtual_text = inline,
  })
end

map('n',        ']e',                vim.diagnostic.goto_next)
map('n',        '[e',                vim.diagnostic.goto_prev)
map('n',        '<leader><leader>e', flip_multiline)
map('n',        '<leader>d',         vim.lsp.buf.hover)
map({'n', 's'}, '<leader>D',         vim.lsp.buf.signature_help)
map('i',        '<C-d>',             vim.lsp.buf.signature_help)
map('n',        '<leader>r',         vim.lsp.buf.rename)
map('n',        '<leader><leader>r', vim.lsp.codelens.run)
map('n',        '<leader>a',         vim.lsp.buf.code_action)

vim.diagnostic.config({
  severity_sort = true,
  signs = false,
  underline = true,
  virtual_lines = not inline,
  virtual_text = inline,
})

vim.cmd([[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
  sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
  sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
  sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
]])
