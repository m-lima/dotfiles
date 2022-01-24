vim.api.nvim_set_keymap('n', ']e', ':lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[e', ':lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })

