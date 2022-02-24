require('gitsigns').setup({
  preview_config = {
    border = 'none',
  },
})

local map = require('script.helper').map

-- Navigation
map('n', ']g', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
map('n', '[g', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

-- Actions
map('n', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
map('v', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
map('n', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
map('v', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
map('n', '<leader>gS',         '<cmd>Gitsigns stage_buffer<CR>')
map('n', '<leader>gu',         '<cmd>Gitsigns undo_stage_hunk<CR>')
map('n', '<leader>gR',         '<cmd>Gitsigns reset_buffer<CR>')
map('n', '<leader>gp',         '<cmd>Gitsigns preview_hunk<CR>')
map('n', '<leader>gb',         '<cmd>lua require("gitsigns").blame_line{full=true}<CR>')
map('n', '<leader><leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
map('n', '<leader>gd',         '<cmd>Gitsigns diffthis<CR>')
map('n', '<leader>gD',         '<cmd>lua require("gitsigns").diffthis("~")<CR>')
map('n', '<leader><leader>gd', '<cmd>Gitsigns toggle_deleted<CR>')

-- Text objects
map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
