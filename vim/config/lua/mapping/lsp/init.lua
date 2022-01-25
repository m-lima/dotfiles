---- LspConfig
vim.api.nvim_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

---- Telescope
vim.api.nvim_set_keymap('n', 'gd', ':Telescope lsp_definitions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ge', ':Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi', ':Telescope lsp_implementations<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', ':Telescope lsp_code_actions<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>S', ':Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':Telescope diagnostics<CR>', { noremap = true, silent = true })

