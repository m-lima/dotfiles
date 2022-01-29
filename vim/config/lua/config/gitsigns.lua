require('gitsigns').setup({
  -- on_attach = function(bufnr)
  --   -- Do mapping here?
  -- end
})

local h = require('script.helper')

h.hi.create('SignifySignAdd', { ctermbg = 'None', guibg = 'None' })
h.hi.create('SignifySignChange', { ctermfg = 141, ctermbg = 'None', guifg = '#af87ff', guibg = 'None' })
h.hi.create('SignifySignDelete', { ctermbg = 'None', guibg = 'None' })

-- Navigation
h.map('n', ']g', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
h.map('n', '[g', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

-- Actions
h.map('n', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
h.map('v', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
h.map('n', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
h.map('v', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
h.map('n', '<leader>gS',         '<cmd>Gitsigns stage_buffer<CR>')
h.map('n', '<leader>gu',         '<cmd>Gitsigns undo_stage_hunk<CR>')
h.map('n', '<leader>gR',         '<cmd>Gitsigns reset_buffer<CR>')
h.map('n', '<leader>gp',         '<cmd>Gitsigns preview_hunk<CR>')
h.map('n', '<leader>gb',         '<cmd>lua require("gitsigns").blame_line{full=true}<CR>')
h.map('n', '<leader><leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
h.map('n', '<leader>gd',         '<cmd>Gitsigns diffthis<CR>')
h.map('n', '<leader>gD',         '<cmd>lua require("gitsigns").diffthis("~")<CR>')
h.map('n', '<leader><leader>gd', '<cmd>Gitsigns toggle_deleted<CR>')

-- Text objects
h.map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
h.map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
