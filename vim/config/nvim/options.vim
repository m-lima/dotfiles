" Enable OSC52
if has('nvim-0.11') && (!empty($SSH_TTY) || !empty($SSH_CLIENT))
  let g:clipboard = 'osc52'
endif

" Flash yanked text
augroup optionsYankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup end

" Do not add comment when using 'o'
" Needs to be an autocmd because `ftplugin` of multiple filetypes set this
" value
augroup optionsOverruleFileTypesOptions
  autocmd!
  autocmd BufEnter * set formatoptions-=o
augroup END

" Personal help files
augroup optionsHelpFile
  autocmd!
  autocmd BufRead *.help set tw=78 ts=8 ft=help norl
augroup END

" Send quickfix to the bottom with full width
augroup optionsQuickfixBottom
  autocmd!
  autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif
augroup END

" Set colorscheme
colorscheme simpalt
