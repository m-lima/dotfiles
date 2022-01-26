---- Telescope

-- Search
vim.api.nvim_set_keymap('n', '<leader><leader>/', '<cmd>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="\'"<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>8', '<cmd>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="\'<C-r>=expand("<cword>")<CR>"<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>*', '<cmd>CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--prompt="Rg> " --add-fzf-arg=--query="\'<C-r>=expand(\'<cword>\')<CR>"<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '?', '<cmd>CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--prompt="Rg> " <space>', { noremap = true, silent = true })

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>p', '<cmd>CocCommand fzf-preview.FromResources project_mru git<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P', '<cmd>CocCommand fzf-preview.DirectoryFiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>o', '<cmd>CocCommand fzf-preview.FromResources buffer project_mru<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>CocCommand fzf-preview.Buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><c-o>', '<cmd>CocCommand fzf-preview.Jumps<CR>', { noremap = true, silent = true })
