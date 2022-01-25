---- Telescope

-- General
vim.api.nvim_set_keymap('n', '<leader><leader><leader>', '<cmd>Telescope resume<CR>', { noremap = true, silent = true })

-- Search
vim.api.nvim_set_keymap('n', '<leader><leader>8', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '?', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>p', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P', '<cmd>Telescope find_files no_ignore=true<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>o', '<cmd>Telescope oldfiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><c-o>', '<cmd>Telescope jumplist<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m', '<cmd>Telescope marks<CR>', { noremap = true, silent = true })

---- Projects
vim.api.nvim_set_keymap('n', '<leader><leader>p', '<cmd>Telescope projects<CR>', { noremap = true, silent = true })

