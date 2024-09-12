" TODO: Shuffle the plugins (bring LSP and TS to the top and link below?)

""" Prepare
highlight clear

if exists('syntax_on')
  syntax reset
endif

set background=dark

if has('termguicolors')
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
highlight! link Added DiffAdd
highlight DiffChange   guifg=#51a0cf ctermfg=74   guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Changed DiffChange
highlight DiffDelete   guifg=#df5f5f ctermfg=167  guibg=NONE    ctermbg=NONE gui=NONE cterm=NONE
highlight! link Removed DiffDelete
highlight DiffText     guifg=NONE    ctermfg=NONE guibg=#800080 ctermbg=90   gui=NONE cterm=NONE

""" Highlights
highlight ColorColumn  guifg=NONE    ctermfg=NONE guibg=#3a3a3a ctermbg=237  gui=NONE cterm=NONE " Too long of a line
highlight Search       guifg=NONE    ctermfg=NONE guibg=#005510 ctermbg=22   gui=NONE cterm=NONE " Search
highlight! link IncSearch Search
highlight CurSearch    guifg=#ffffff ctermfg=15   guibg=#20a050 ctermbg=35   gui=NONE cterm=NONE " Current Search
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
highlight MsgArea guifg=#eeeeee ctermfg=255 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight! link ErrorMsg   DiagnosticError
highlight! link WarningMsg DiagnosticWarn

""" Text
highlight Type           guifg=#009980 ctermfg=36  guibg=NONE ctermbg=NONE gui=BOLD      cterm=BOLD
highlight Typedef        guifg=#009980 ctermfg=36  guibg=NONE ctermbg=NONE gui=BOLD      cterm=BOLD
highlight StorageClass   guifg=#009999 ctermfg=37  guibg=NONE ctermbg=NONE gui=BOLD      cterm=BOLD
highlight Character      guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight String         guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Boolean        guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Keyword        guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Tag            guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Define         guifg=#4ec9b0 ctermfg=79  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Identifier     guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Label          guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Structure      guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Float          guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Number         guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight SpecialChar    guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Conditional    guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Exception      guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Include        guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight PreProc        guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Repeat         guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Statement      guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Underlined     guifg=#d7ba7d ctermfg=180 guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight Constant       guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Function       guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Macro          guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight SpecialKey     guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Comment        guifg=#ff5faf ctermfg=205 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight SpecialComment guifg=#ff8787 ctermfg=210 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Delimiter      guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Operator       guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Special        guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight Debug          guifg=#dadada ctermfg=253 guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE

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
highlight LspReferenceText     guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspReferenceWrite    guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspReferenceRead     guifg=#ffffff ctermfg=15  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspCodeLens          guifg=#005f5f ctermfg=23  guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
highlight LspCodeLensType      guifg=#005f5f ctermfg=23  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight LspCodeLensSeparator guifg=#008787 ctermfg=30  guibg=NONE ctermbg=NONE gui=NONE      cterm=NONE
highlight! link LspCodeLensMark LspCodeLensSeparator

highlight! link LspSignatureActiveParameter Search

" TreeSitter
if has('nvim-0.8')
  highlight @operator                          guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @punctuation.bracket               guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @punctuation.delimiter             guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @punctuation.special               guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.uri                          guifg=#a8a8a8 ctermfg=248 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.literal                      guifg=#b2b2b2 ctermfg=249 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.emphasis                     guifg=#b2b2b2 ctermfg=249 guibg=NONE ctermbg=NONE gui=ITALIC cterm=ITALIC
  highlight @constant                          guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @annotation                        guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @function.builtin                  guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @function                          guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @function.macro                    guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @method                            guifg=#dcdcaa ctermfg=187 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @constant.builtin                  guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @boolean                           guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @keyword                           guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @keyword.function                  guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @keyword.operator                  guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @type.builtin                      guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @tag                               guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.title                        guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
  highlight @text.strong                       guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
  highlight @constant.macro                    guifg=#4ec9b0 ctermfg=79  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @attribute                         guifg=#4ec9b0 ctermfg=79  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @namespace                         guifg=#4ec9b0 ctermfg=79  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @constructor                       guifg=#4ec9b0 ctermfg=79  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @type                              guifg=#009980 ctermfg=36  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
  highlight @structure                         guifg=#009980 ctermfg=36  guibg=NONE ctermbg=NONE gui=BOLD   cterm=BOLD
  highlight @label                             guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @string.regex                      guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @string                            guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @character                         guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.reference                    guifg=#6a9955 ctermfg=65  guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @string.escape                     guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight markdown@punctuation.special       guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @number                            guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @float                             guifg=#b5cea8 ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @parameter                         guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @parameter.reference               guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @field                             guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @property                          guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @variable                          guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @variable.builtin                  guifg=#9cdcfe ctermfg=117 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @include                           guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @conditional                       guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @repeat                            guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @exception                         guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text                              guifg=#d7ba7d ctermfg=180 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @text.underline                    guifg=#d7ba7d ctermfg=180 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE
  highlight @tag.delimiter                     guifg=#909090 ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE   cterm=NONE

  highlight! link @error        DiagnosticError
  highlight! link @text.error   DiagnosticError
  highlight! link @text.danger  DiagnosticError
  highlight! link @text.warning DiagnosticWarn
  highlight! link @text.note    DiagnosticInfo
  highlight! link @text.todo    Todo
endif

" LSP Semantic Tokens
if has('nvim-0.9')
  highlight! link @lsp.type.class         @structure
  highlight! link @lsp.type.decorator     @function
  highlight! link @lsp.type.enum          @structure
  highlight! link @lsp.type.enumMember    @constant
  highlight! link @lsp.type.function      @function
  highlight! link @lsp.type.interface     @type
  highlight! link @lsp.type.macro         @constant.macro
  highlight! link @lsp.type.method        @method
  highlight! link @lsp.type.namespace     @namespace
  highlight! link @lsp.type.parameter     @parameter
  highlight! link @lsp.type.property      @property
  highlight! link @lsp.type.struct        @structure
  highlight! link @lsp.type.type          @type
  highlight! link @lsp.type.typeParameter @parameter
  highlight! link @lsp.type.variable      @variable

  highlight! link @lsp.mod.constant       @constant

  highlight DiagnosticUnnecessary         guifg=#606060 ctermfg=240
endif

" QuickScope
highlight! link QuickScopePrimary   Visual
highlight! link QuickScopeSecondary Search

" CMP
if has('nvim-0.4')
  highlight CmpItemAbbrDeprecated  guifg=#51504f ctermfg=239 guibg=NONE ctermbg=NONE gui=STRIKETHROUGH cterm=STRIKETHROUGH
else
  highlight CmpItemAbbrDeprecated  guifg=#51504f ctermfg=239 guibg=NONE ctermbg=NONE gui=UNDERLINE cterm=UNDERLINE
endif
highlight CmpItemAbbrMatch       guifg=#569cd6 ctermfg=74  guibg=NONE ctermbg=NONE gui=BOLD cterm=BOLD
highlight CmpItemKindEvent       guifg=#87afaf ctermfg=103 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight CmpItemKindText        guifg=#9c50a0 ctermfg=133 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight CmpItemKindType        guifg=#009980 ctermfg=36  guibg=NONE ctermbg=NONE gui=NONE cterm=NONE " Matching @type without BOLD
highlight CmpItemKindUnit        guifg=#909090 ctermfg=245 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
highlight CmpItemKindSnippet     guifg=#afd7af ctermfg=151 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

highlight! link CmpItemKindClass         CmpItemKindType
highlight! link CmpItemKindEnum          CmpItemKindType
highlight! link CmpItemKindInterface     CmpItemKindType
highlight! link CmpItemKindStruct        CmpItemKindType

highlight! link CmpItemKindConstant      Constant
highlight! link CmpItemKindConstructor   Define
highlight! link CmpItemKindField         Identifier
highlight! link CmpItemKindFunction      Function
highlight! link CmpItemKindKeyword       Keyword
highlight! link CmpItemKindMethod        Function
highlight! link CmpItemKindOperator      Operator
highlight! link CmpItemKindParam         Identifier
highlight! link CmpItemKindProperty      Tag
highlight! link CmpItemKindTypeParameter Identifier
highlight! link CmpItemKindVariable      Identifier

highlight! link CmpItemKindColor         Constant
highlight! link CmpItemKindEnumMember    Identifier
highlight! link CmpItemKindFile          Keyword
highlight! link CmpItemKindFolder        Keyword
highlight! link CmpItemKindModule        Include
highlight! link CmpItemKindReference     Identifier
highlight! link CmpItemKindTabNine       CmpItemKindEvent
highlight! link CmpItemKindValue         Label

" Telescope
highlight! link TelescopeSelection PmenuSel
highlight! link TelescopeMatching  CmpItemAbbrMatch

" Git-conflict
highlight GitConflictAncestorBase guifg=NONE ctermfg=NONE guibg=#303030 ctermbg=236 gui=NONE cterm=NONE
highlight GitConflictCurrentBase  guifg=NONE ctermfg=NONE guibg=#202030 ctermbg=17  gui=NONE cterm=NONE
highlight GitConflictIncomingBase guifg=NONE ctermfg=NONE guibg=#203020 ctermbg=22  gui=NONE cterm=NONE
