---- Telescope

-- General
vim.api.nvim_set_keymap('n', '<leader><leader><leader>', ':Telescope resume<CR>', { noremap = true, silent = true })

-- Search
vim.api.nvim_set_keymap('n', '<leader><leader>8', ':Telescope grep_string<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '?', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>p', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P', ':Telescope find_files no_ignore=true<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>o', ':Telescope oldfiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><c-o>', ':Telescope jumplist<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m', ':Telescope marks<CR>', { noremap = true, silent = true })

---- Projects
vim.api.nvim_set_keymap('n', '<leader><leader>p', ':Telescope projects<CR>', { noremap = true, silent = true })

