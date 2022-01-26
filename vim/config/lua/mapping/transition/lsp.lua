---- LspConfig
vim.api.nvim_set_keymap('n', ']e', '<Plug>(coc-diagnostic-next)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[e', '<Plug>(coc-diagnostic-prev)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>CocCommand fzf-preview.CocDiagnostics<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>r', '<Plug>(coc-rename)', { noremap = true, silent = true })

---- Telescope
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ge', '<cmd>CocCommand fzf-preview.CocReferences<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi', '<cmd>CocCommand fzf-preview.CocImplementations<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', '<Plug>(coc-codelens-action)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>CocCommand fzf-preview.CocOutline<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>CocCommand fzf-preview.CocDiagnostics<CR>', { noremap = true, silent = true })

