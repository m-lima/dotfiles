" vim: et sw=2 sts=2

" Plugin:      https://github.com/m-lima/vim-grayalt
" Description: A 256 colors colorscheme for Vim.
" Maintainer:  Marcelo Lima <http://github.com/m-lima>

highlight clear

if exists('syntax_on')
  syntax reset
endif

set background=dark

if has("termguicolors")
  set termguicolors
endif

""""
" TODO: Make colors less contrasting. Leave the high contrast for hl that need to be seen
""""

let g:colors_name = 'grayalt'

""" Base
if exists('g:grayalt_opaque_bg') && g:grayalt_opaque_bg
  highlight Normal guifg=#909090 ctermfg=245 guibg=#262626 gui=NONE cterm=NONE
else
  highlight Normal guifg=#909090 ctermfg=245 guibg=NONE    gui=NONE cterm=NONE
endif

" Built-in
highlight ColorColumn guifg=NONE ctermfg=NONE guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE

" Misc

highlight  Comment      guifg=#ff557c  ctermfg=204  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
" highlight  Constant     guifg=#5e8759  ctermfg=202  guibg=NONE  ctermbg=NONE  gui=bold       cterm=bold
highlight  Constant     guifg=#78a67d  ctermfg=108  guibg=NONE  ctermbg=NONE  gui=bold       cterm=bold
" highlight  Constant     guifg=#87afdf  ctermfg=110  guibg=NONE  ctermbg=NONE  gui=bold       cterm=bold
highlight  Conceal      guifg=#606060  ctermfg=240  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Directory    guifg=#ffaf87  ctermfg=216  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  EndOfBuffer  guifg=#262626  ctermfg=235  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Identifier   guifg=#ffaf87  ctermfg=216  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
" NEW highlight  Identifier   guifg=#d7875f  ctermfg=173  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  MatchParen   guifg=#ff305f  ctermfg=201  guibg=NONE  ctermbg=NONE  gui=underline  cterm=underline
highlight  NonText      guifg=#ff00af  ctermfg=201  guibg=NONE  ctermbg=NONE  gui=bold       cterm=bold
highlight  Number       guifg=#87dfdf  ctermfg=116  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
" NEW highlight  Number       guifg=#5fafaf  ctermfg=73   guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  PreProc      guifg=#ffdfaf  ctermfg=223  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
" NEW highlight  PreProc      guifg=#d7af87  ctermfg=180  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Special      guifg=#dfafaf  ctermfg=181  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  SpecialKey   guifg=#ff005f  ctermfg=201  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Statement    guifg=#afdf87  ctermfg=150  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  String       guifg=#5e8759  ctermfg=065  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Title        guifg=#afff87  ctermfg=156  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Todo         guifg=#ffdfaf  ctermfg=223  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE
highlight  Type         guifg=#c57825  ctermfg=172  guibg=NONE  ctermbg=NONE  gui=bold       cterm=bold
highlight  VertSplit    guifg=#3a3a3a  ctermfg=237  guibg=NONE  ctermbg=NONE  gui=NONE       cterm=NONE

highlight link DiagnosticError DiffDelete

" Cursor lines

" Strong background
" highlight CursorColumn ctermfg=NONE guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
" highlight CursorLine ctermfg=NONE guibg=#343434 ctermbg=236 gui=NONE cterm=NONE
" Soft background
highlight  CursorLine    ctermfg=NONE  guibg=#303030  ctermbg=236   gui=NONE  cterm=NONE

" Number column

" Strong background
" highlight CursorLineNr guifg=#878787 ctermfg=102 guibg=#404040 ctermbg=239 gui=NONE cterm=NONE
" highlight LineNr guifg=#878787 ctermfg=102 guibg=#323232 ctermbg=237 gui=NONE cterm=NONE
" Soft background
highlight CursorLineNr guifg=#b7b75f ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight LineNr guifg=#878787 ctermfg=102 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

" Tabline

highlight TabLine guifg=#808080 ctermfg=244 guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
highlight TabLineFill guifg=#dfdfaf ctermfg=187 guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
highlight TabLineSel guifg=#e4e4e4 ctermfg=254 guibg=#303030 ctermbg=236 gui=bold cterm=bold

" Statusline

highlight StatusLine guifg=#e4e4e4 ctermfg=254 guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE
highlight StatusLineNC guifg=#808080 ctermfg=244 guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE

" Color column

highlight ColorColumn ctermfg=NONE guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE

" Diff & Signs

" highlight SignColumn ctermfg=NONE guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE
" Hard background
" highlight SignColumn guifg=#888888 ctermfg=060 guibg=#323232 ctermbg=236 gui=NONE cterm=NONE
" Soft background
highlight SignColumn guifg=#888888 ctermfg=060 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

highlight DiffAdd guifg=#87ff5f ctermfg=119 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight DiffDelete guifg=#df5f5f ctermfg=167 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight DiffChange guifg=#51a0cf ctermfg=74 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight DiffText guifg=#ff5f5f ctermfg=203 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

" Plugin: vim-signify
" highlight SignifySignAdd guifg=#87ff5f ctermfg=119 guibg=NONE ctermbg=NONE gui=bold cterm=bold
" highlight SignifySignDelete guifg=#df5f5f ctermfg=167 guibg=NONE ctermbg=NONE gui=bold cterm=bold
" highlight SignifySignChange guifg=#51a0cf ctermfg=74 guibg=NONE ctermbg=NONE gui=bold cterm=bold

" Folds

highlight FoldColumn ctermfg=102 ctermbg=237 cterm=NONE guifg=#878787 guibg=#3a3a3a gui=NONE
highlight Folded ctermfg=102 ctermbg=237 cterm=NONE guifg=#878787 guibg=#3a3a3a gui=NONE

" Search

highlight IncSearch guifg=#c0c0c0 ctermfg=7 guibg=#005fff ctermbg=27 gui=NONE cterm=NONE
highlight Search guifg=#c0c0c0 ctermfg=7 guibg=#df005f ctermbg=161 gui=NONE cterm=NONE

" Messages

highlight Error guifg=#eeeeee ctermfg=255 guibg=#df0000 ctermbg=160 gui=NONE cterm=NONE
highlight ErrorMsg guifg=#eeeeee ctermfg=255 guibg=#df0000 ctermbg=160 gui=NONE cterm=NONE
highlight ModeMsg guifg=#afff87 ctermfg=156 guibg=NONE ctermbg=NONE gui=bold cterm=bold
highlight MoreMsg guifg=#c0c0c0 ctermfg=7 guibg=#005fdf ctermbg=26 gui=NONE cterm=NONE
highlight WarningMsg guifg=#c0c0c0 ctermfg=7 guibg=#005fdf ctermbg=26 gui=NONE cterm=NONE

" Visual

highlight Visual guifg=#c0c0c0 ctermfg=7 guibg=#005f87 ctermbg=24 gui=NONE cterm=NONE
highlight VisualNOS guifg=#c0c0c0 ctermfg=7 guibg=#5f5f87 ctermbg=60 gui=NONE cterm=NONE

" Pmenu

highlight Pmenu guifg=#e4e4e4 ctermfg=254 guibg=#3a3a3a ctermbg=237 gui=NONE cterm=NONE
highlight PmenuSbar ctermfg=NONE guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
highlight PmenuSel guifg=#df5f5f ctermfg=167 guibg=#444444 ctermbg=238 gui=bold cterm=bold
highlight PmenuThumb ctermfg=NONE guibg=#df5f5f ctermbg=167 gui=NONE cterm=NONE
highlight WildMenu guifg=#df5f5f ctermfg=161 guibg=#3a3a3a ctermbg=237 gui=bold cterm=bold

" Spell
highlight SpellBad guifg=#c0c0c0 ctermfg=7 guibg=#df5f5f ctermbg=167 gui=NONE cterm=NONE
highlight SpellCap guifg=#c0c0c0 ctermfg=7 guibg=#005fdf ctermbg=26 gui=NONE cterm=NONE
highlight SpellLocal guifg=#c0c0c0 ctermfg=7 guibg=#8700af ctermbg=91 gui=NONE cterm=NONE
highlight SpellRare guifg=#c0c0c0 ctermfg=7 guibg=#00875f ctermbg=29 gui=NONE cterm=NONE

" Quickfix
highlight qfLineNr    ctermfg=238 ctermbg=NONE cterm=NONE guifg=#444444 guibg=NONE gui=NONE
highlight qfSeparator ctermfg=243 ctermbg=NONE cterm=NONE guifg=#767676 guibg=NONE gui=NONE

" Plugin: vim-easymotion
highlight EasyMotionTarget guifg=#ffff5f ctermfg=227 guibg=NONE ctermbg=NONE gui=bold cterm=bold
highlight EasyMotionTarget2First guifg=#df005f ctermfg=161 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight EasyMotionTarget2Second guifg=#ffff5f ctermfg=227 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

" Plugin: vim-rfc
highlight RFCType guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight RFCID guifg=#ffaf5f ctermfg=215 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight RFCTitle guifg=#eeeeee ctermfg=255 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight RFCDelim guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

" Plugin: vim-startify
highlight StartifyBracket guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifyFile guifg=#eeeeee ctermfg=255 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifyFooter guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifyHeader guifg=#87df87 ctermfg=114 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifyNumber guifg=#ffaf5f ctermfg=215 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifyPath guifg=#8a8a8a ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifySection guifg=#dfafaf ctermfg=181 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifySelect guifg=#5fdfff ctermfg=81 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifySlash guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight StartifySpecial guifg=#585858 ctermfg=240 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

" Plugin: lsp
highlight LspReferenceText guifg=#ffffff ctermfg=15 guibg=NONE ctermbg=NONE gui=underline cterm=underline
highlight LspReferenceWrite guifg=#ffffff ctermfg=15 guibg=NONE ctermbg=NONE gui=underline cterm=underline
highlight LspReferenceRead guifg=#ffffff ctermfg=15 guibg=NONE ctermbg=NONE gui=underline cterm=underline
highlight LspCodeLens guifg=#005f5f ctermfg=23 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
