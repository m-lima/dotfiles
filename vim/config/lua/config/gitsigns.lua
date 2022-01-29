require('gitsigns').setup({
  -- on_attach = function(bufnr)
  --   -- Do mapping here?
  -- end
})

vim.highlight.create('SignifySignAdd', { ctermbg = 'None', guibg = 'None' })
vim.highlight.create('SignifySignChange', { ctermfg = 141, ctermbg = 'None', guifg = '#af87ff', guibg = 'None' })
vim.highlight.create('SignifySignDelete', { ctermbg = 'None', guibg = 'None' })

-- Navigation
vim.api.nvim_set_keymap('n', ']g', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', '[g', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { noremap = true, silent = true, expr = true })

-- Actions
vim.api.nvim_set_keymap('n', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gS',         '<cmd>Gitsigns stage_buffer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gu',         '<cmd>Gitsigns undo_stage_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gR',         '<cmd>Gitsigns reset_buffer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gp',         '<cmd>Gitsigns preview_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gb',         '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd',         '<cmd>Gitsigns diffthis<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gD',         '<cmd>lua require"gitsigns".diffthis("~")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>gd', '<cmd>Gitsigns toggle_deleted<CR>', { noremap = true, silent = true })

-- Text objects
vim.api.nvim_set_keymap('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>', { noremap = true, silent = true })
