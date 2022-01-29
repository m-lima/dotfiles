local h = require('script.helper')

h.map('n', ']e',                '<cmd>lua vim.diagnostic.goto_next()<CR>')
h.map('n', '[e',                '<cmd>lua vim.diagnostic.goto_prev()<CR>')
h.map('n', '<leader>d',         '<cmd>lua vim.lsp.buf.hover()<CR>')
h.map('n', '<leader><leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')

h.hi.create('LspReferenceText', { ctermfg = 15, guifg = '#ffffff', gui='underline' })
h.hi.create('LspReferenceWrite', { ctermfg = 15, guifg = '#ffffff', gui='underline' })
h.hi.create('LspReferenceRead', { ctermfg = 15, guifg = '#ffffff', gui='underline' })
h.hi.create('LspCodeLens', { ctermfg = 37, guifg = '#00afaf' })
