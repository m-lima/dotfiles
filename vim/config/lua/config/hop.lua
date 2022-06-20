local hop = require('hop')
local hop_hint = require('hop.hint')

hop.setup({})

local map = require('script.helper').map

map({'n', 'v'}, '<leader>f', function() hop.hint_char1({ direction = hop_hint.HintDirection.AFTER_CURSOR, current_line_only = true }) end)
map({'n', 'v'}, '<leader>F', function() hop.hint_char1({ direction = hop_hint.HintDirection.BEFORE_CURSOR, current_line_only = true }) end)
map('o',        '<leader>f', function() hop.hint_char1({ direction = hop_hint.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true }) end)
map('o',        '<leader>F', function() hop.hint_char1({ direction = hop_hint.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true }) end)
map({'n', 'v'}, '<leader>g', function() hop.hint_words({ hint_position = hop_hint.HintPosition.END }) end)
map('o',        '<leader>g', function() hop.hint_words({ hint_position = hop_hint.HintPosition.END, inclusive_jump = true }) end)
