---- Fugitive
vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>Git blame<CR>', { noremap = true, silent = true })

---- GitGutter
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>GitGutterToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>GitGutterToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>GitGutterToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gs', '<cmd>GitGutterStageHunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gu', '<cmd>GitGutterUndoHunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gp', '<cmd>GitGutterPreviewHunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gl', '<cmd>GitGutterQuickFix<CR>:copen<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gf', '<cmd>GitGutterFold<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']g',         '<cmd>GitGutterNextHunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[g',         '<cmd>GitGutterPrevHunk<CR>', { noremap = true, silent = true })
