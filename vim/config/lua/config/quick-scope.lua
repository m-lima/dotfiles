vim.g.qs_highlight_on_keys = { 'f', 'F' }

local h = require('script.helper')
h.hi.link('QuickScopePrimary', 'Visual')
h.hi.link('QuickScopeSecondary', 'Search')
