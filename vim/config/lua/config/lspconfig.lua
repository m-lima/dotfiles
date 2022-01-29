local map = require('script.helper').map

map('n', ']e',                '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '[e',                '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', '<leader>d',         '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader><leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')
