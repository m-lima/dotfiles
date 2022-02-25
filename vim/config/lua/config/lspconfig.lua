local map = require('script.helper').map

map('n', ']e',                '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '[e',                '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', '<leader>d',         '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader><leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<leader>r',         '<cmd>lua vim.lsp.codelens.run()<CR>')

vim.diagnostic.config({
  severity_sort = true,
})

vim.cmd([[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=
]])
