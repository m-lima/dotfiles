require('config.lspconfig.servers').setup()
local map = require('util').map

map('n',        ']e',                vim.diagnostic.goto_next)
map('n',        '[e',                vim.diagnostic.goto_prev)
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
})

vim.cmd([[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
  sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
  sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
  sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
]])
