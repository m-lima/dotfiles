require('gitsigns').setup({
  on_attach = function(bufnr)
    require('mapping.git')
  end
})

vim.highlight.create('SignifySignAdd', { ctermbg = 'None', guibg = 'None' })
vim.highlight.create('SignifySignChange', { ctermfg = 141, ctermbg = 'None', guifg = '#af87ff', guibg = 'None' })
vim.highlight.create('SignifySignDelete', { ctermbg = 'None', guibg = 'None' })
