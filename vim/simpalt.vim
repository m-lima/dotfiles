" TODO: Match TreeSitter with regular hl
" TODO: Shuffle the plugins (bring LSP and TS to the top and link below?)

""" Prepare
highlight clear

if exists('syntax_on')
  syntax reset
endif

set background=dark

if has("termguicolors")
  set termguicolors
endif

let g:colors_name = 'simpalt'

""" Base
if exists('g:simpalt_transparent_bg') && g:simpalt_transparent_bg
  highlight Normal guifg=#909090 ctermfg=245 guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
else
  highlight Normal guifg=#909090 ctermfg=245 guibg=#262626 ctermbg=235  gui=NONE cterm=NONE
endif

""" General
highlight Directory    guifg=#a8a8a8 ctermfg=248  guibg=NONE    ctermbg=NONE gui=BOLD cterm=BOLD
highlight EndOfBuffer  guifg=#262626 ctermfg=235  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link QuickFixLine PmenuSel
highlight StatusLine   guifg=#e4e4e4 ctermfg=254  guibg=#3a3a3a ctermbg=237  gui=NONE cterm=NONE
highlight StatusLineNC guifg=#808080 ctermfg=244  guibg=#3a3a3a ctermbg=237  gui=NONE cterm=NONE
highlight! link TabLine Normal
highlight! link TabLineFill Normal
highlight TabLineSel   guifg=#aaaaaa ctermfg=244  guibg=#303030 ctermbg=236  gui=NONE cterm=NONE
highlight Title        guifg=#afff87 ctermfg=156  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE

""" Windowing
highlight FloatBorder  guifg=#585858 ctermfg=240  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight Pmenu        guifg=#bcbcbc ctermfg=250  guibg=#1c1c1c ctermbg=234  gui=NONE cterm=NONE
highlight PmenuSbar    guifg=NONE    ctermfg=NONE guibg=#3a3a3a ctermbg=237  gui=NONE cterm=NONE
highlight PmenuSel     guifg=NONE    ctermfg=NONE guibg=#004b72 ctermbg=24   gui=NONE cterm=NONE
highlight PmenuThumb   guifg=NONE    ctermfg=NONE guibg=#bcbcbc ctermbg=250  gui=NONE cterm=NONE
highlight WinSeparator guifg=#444444 ctermfg=238  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE

""" Position
highlight CursorLine   guifg=NONE    ctermfg=NONE guibg=#303030 ctermbg=236  gui=NONE cterm=NONE
highlight CursorLineNr guifg=#bcbcbc ctermfg=250  guibg=NONE    ctermbg=NONE gui=BOLD cterm=BOLD
highlight LineNr       guifg=#585858 ctermfg=240  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight clear SignColumn

""" Diff
highlight DiffAdd      guifg=#87ff5f ctermfg=119  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight DiffChange   guifg=#51a0cf ctermfg=74   guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight DiffDelete   guifg=#df5f5f ctermfg=167  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight link DiffText DiffDelete

""" Highlights
highlight ColorColumn  guifg=NONE    ctermfg=NONE guibg=#3a3a3a ctermbg=237  gui=NONE cterm=NONE " Too long of a line
highlight Search       guifg=NONE    ctermbg=NONE guibg=#005510 ctermbg=22   gui=NONE cterm=NONE " Search
highlight! link IncSearch Search
highlight Visual       guifg=NONE    ctermfg=NONE guibg=#264f78 ctermbg=24   gui=NONE cterm=NONE " Selection
highlight! link VisualNOS Visual
highlight MatchParen   guifg=#ff307f ctermfg=198  guibg=NONE    ctermbg=NONE gui=BOLD cterm=BOLD " Parens
highlight NonText      guifg=#ff00af ctermfg=199  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE " Whitespace
highlight Conceal      guifg=#606060 ctermfg=240  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE " The opposite of highlight
highlight Todo         guifg=#d7ba7d ctermfg=180  guibg=NONE    ctermbg=NONE gui=BOLD cterm=BOLD " Todo

""" Diagnostics (LSP Plugin)
highlight DiagnosticError   guifg=#df5f5f ctermfg=167 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight DiagnosticWarn    guifg=#ffaf00 ctermfg=214 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight DiagnosticInfo    guifg=#51a0cf ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight DiagnosticHint    guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE

""" Command
highligh MsgArea guifg=#eeeeee ctermfg=255 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight! link ErrorMsg   DiagnosticError
highlight! link WarningMsg DiagnosticWarn

""" Text
highlight Comment      guifg=#ff5faf ctermfg=205  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link SpecialComment Comment
highlight Statement    guifg=#c586c0 ctermfg=175  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Define      Statement
highlight! link Exception   Statement
highlight! link Label       Statement
highlight! link PreProc     Statement
highlight! link Repeat      Statement
highlight Keyword      guifg=#26a087 ctermfg=36   guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Conditional Keyword
highlight! link Include     Keyword
highlight Macro        guifg=#ce9178 ctermfg=174  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight String       guifg=#6a9955 ctermfg=65   guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Character String
highlight Constant     guifg=#26a087 ctermfg=36   guibg=NONE    ctermbg=NONE gui=BOLD cterm=BOLD
highlight! link Boolean      Constant
highlight! link SpecialKey   Constant
highlight Type         guifg=#569cd6 ctermfg=74   guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link StorageClass Type
highlight! link Structure    Type
highlight! link Typedef      Type
highlight! link SpecialKey   Type
highlight Operator     guifg=#909090 ctermfg=245  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link SpecialChar Operator
highlight! link Tag         Operator
highlight Delimiter    guifg=#707070 ctermfg=241  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight Number       guifg=#b5cea8 ctermfg=151  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Float Number
highlight Identifier   guifg=#9cdcfe ctermfg=117  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight Special      guifg=#d7ba7d ctermfg=180  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight Function     guifg=#dcdcaa ctermfg=187  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE

""" Plugins
" NeoTree
if !(exists('g:simpalt_transparent_nvimtree') && g:simpalt_transparent_nvimtree)
  highlight NeoTreeNormal       guifg=#909090 ctermfg=245  guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
  highlight NeoTreeNormalNC     guifg=#909090 ctermfg=245  guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
  highlight NeoTreeVertSplit    guifg=#262626 ctermfg=235  guibg=#262626 ctermbg=235 gui=NONE cterm=NONE
  highlight NeoTreeWinSeparator guifg=#262626 ctermfg=235  guibg=#262626 ctermbg=235 gui=NONE cterm=NONE
  highlight NeoTreeCursorLine   guifg=NONE    ctermfg=NONE guibg=#262626 ctermbg=235 gui=NONE cterm=NONE
endif

" LSP
highlight LspReferenceText  guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspReferenceWrite guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspReferenceRead  guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspCodeLens       guifg=#005f5f ctermfg=23  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE

highlight! link LspSignatureActiveParameter Search

" TreeSitter
highlight TSOperator           guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSPunctBracket       guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSPunctDelimiter     guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSPunctSpecial       guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSURI                guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSLiteral            guifg=#b2b2b2 ctermfg=249 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE " Links to String
highlight TSEmphasis           guifg=#b2b2b2 ctermfg=249 guibg=NONE ctermbg=NONE gui=ITALIC cterm=ITALIC
highlight TSConstant           guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE " Mismatch
highlight TSAnnotation         guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSFuncBuiltin        guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSFunction           guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSFuncMacro          guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSMethod             guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSConstBuiltin       guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSBoolean            guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSKeyword            guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSKeywordFunction    guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSKeywordOperator    guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSTypeBuiltin        guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSTag                guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSTitle              guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
highlight TSStrong             guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
highlight TSConstMacro         guifg=#4ec9b0 ctermfg=77  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSAttribute          guifg=#4ec9b0 ctermfg=77  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSNamespace          guifg=#4ec9b0 ctermfg=77  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSConstructor        guifg=#4ec9b0 ctermfg=77  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSType               guifg=#009980 ctermfg=72  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD " Mismatch
highlight TSStringRegex        guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSString             guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSCharacter          guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSTextReference      guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSStringEscape       guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSNumber             guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSFloat              guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSParameter          guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSParameterReference guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSField              guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSProperty           guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSLabel              guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSStructure          guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSVariable           guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSVariableBuiltin    guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSInclude            guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSConditional        guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSRepeat             guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSException          guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSText               guifg=#d7ba7d ctermfg=180 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSUnderline          guifg=#d7ba7d ctermfg=180 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
highlight TSTagDelimiter       guifg=#909090 ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE

highligh! link TSError   DiagnosticError
highligh! link TSDanger  DiagnosticError
highligh! link TSWarning DiagnosticWarn
highligh! link TSNote    DiagnosticInfo

" QuickScope
highlight! link QuickScopePrimary   Visual
highlight! link QuickScopeSecondary Search

" CMP
highlight CmpItemAbbrDeprecated  guifg=#51504f ctermfg=239 guibg=NONE ctermbg=NONE gui=STRIKETHROUGH cterm=STRIKETHROUGH
highlight CmpItemAbbrMatch       guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD          cterm=BOLD
highlight CmpItemKindEvent       guifg=#87afaf ctermfg=103 guibg=NONE ctermbg=NONE gui=NONE          cterm=NONE
highlight CmpItemKindText        guifg=#9c50a0 ctermfg=133 guibg=NONE ctermbg=NONE gui=NONE          cterm=NONE
highlight CmpItemKindType        guifg=#009980 ctermfg=72  guibg=NONE ctermbg=NONE gui=NONE          cterm=NONE " Matching TSType without BOLD
highlight CmpItemKindUnit        guifg=#909090 ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE          cterm=NONE
highlight CmpItemKindSnippet     guifg=#afd7af ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE          cterm=NONE

highlight! link CmpItemKindClass         CmpItemKindType
highlight! link CmpItemKindEnum          CmpItemKindType
highlight! link CmpItemKindInterface     CmpItemKindType
highlight! link CmpItemKindStruct        CmpItemKindType

highlight! link CmpItemKindConstant      TSConstant
highlight! link CmpItemKindConstructor   TSConstructor
highlight! link CmpItemKindField         TSField
highlight! link CmpItemKindFunction      TSFunction
highlight! link CmpItemKindKeyword       TSKeyword
highlight! link CmpItemKindMethod        TSMethod
highlight! link CmpItemKindOperator      TSOperator
highlight! link CmpItemKindParam         TSParameter
highlight! link CmpItemKindProperty      TSProperty
highlight! link CmpItemKindTypeParameter TSParameter
highlight! link CmpItemKindVariable      TSVariable

highlight! link CmpItemKindColor         TSConstant
highlight! link CmpItemKindEnumMember    TSVariable
highlight! link CmpItemKindFile          TSKeyword
highlight! link CmpItemKindFolder        TSKeyword
highlight! link CmpItemKindModule        TSInclude
highlight! link CmpItemKindReference     TSParameterReference
highlight! link CmpItemKindTabNine       CmpItemKindEvent
highlight! link CmpItemKindValue         TSLabel

" Telescope
highlight! link TelescopeSelection PmenuSel
highlight! link TelescopeMatching  CmpItemAbbrMatch

" Git-conflict
highlight GitConflictAncestorBase guifg=NONE ctermfg=NONE guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
highlight GitConflictCurrentBase  guifg=NONE ctermfg=NONE guibg=#202030 ctermbg=17  gui=NONE cterm=NONE
highlight GitConflictIncomingBase guifg=NONE ctermfg=NONE guibg=#203020 ctermbg=22  gui=NONE cterm=NONE
