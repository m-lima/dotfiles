local map = require('script.helper').map

map('n', '<F2>',         '<Plug>VimspectorLaunch',           { noremap = false })
map('n', '<leader><F2>', '<cmd>VimspectorReset<CR>')
map('n', '<F3>',         '<Plug>VimspectorStop',             { noremap = false })
map('n', '<F4>',         '<Plug>VimspectorRestart',          { noremap = false })
map('n', '<F5>',         '<Plug>VimspectorContinue',         { noremap = false })
map('n', '<F6>',         '<Plug>VimspectorRunToCursor',      { noremap = false })
map('n', '<F7>',         '<Plug>VimspectorStepInto',         { noremap = false })
map('n', '<F8>',         '<Plug>VimspectorStepOver',         { noremap = false })
map('n', '<F9>',         '<Plug>VimspectorToggleBreakpoint', { noremap = false })
map('n', '<F10>',        '<Plug>VimspectorBalloonEval',      { noremap = false })
map('x', '<F10>',        '<Plug>VimspectorBalloonEval',      { noremap = false })
