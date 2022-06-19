""""""""""""""""""""
" Plugins install
""""""""""""""""""""

call plug#begin()

""" Dependencies
Plug 'kana/vim-textobj-user' " Dependency for text objects
Plug 'tpope/vim-repeat' " Depenency for vim-scripts/ReplaceWithRegister
Plug 'ryanoasis/vim-devicons'

""" Util
Plug 'tpope/vim-commentary'            " gc
Plug 'vim-scripts/ReplaceWithRegister' " gr

" Text objects
Plug 'kana/vim-textobj-indent'         " i
Plug 'kana/vim-textobj-entire'         " e
Plug 'glts/vim-textobj-comment'        " c

call plug#end()

""""""""""""""""""""
" Plugins config
""""""""""""""""""""

""" Vim-commentary
augroup pluginsVimComentary
  autocmd!

  " Custom comment strings
  autocmd FileType cmake setlocal commentstring=#\ %s
  autocmd FileType cpp,hpp,c,h,cc,hh,cl,tf,zig setlocal commentstring=//\ %s
  autocmd FileType toml setlocal commentstring=#\ %s
augroup END

""""""""""""""""""""
" Tips
""""""""""""""""""""

" :checkhealth        Check the health of the plugins

" :w<CR> :e #         [Saves and open last save]
" s                   [Changes character]
" :noh                [Turn highlight off]
" :vert res <NUM>     [Resize split vertically to N]
" gg=G                [Indent the whole file]
" ~                   [Toggle case]
" ''                  [Go back to previous position]

" va}a}a}...a}        [Select larger and larger scope]

" has('win32')        [Windows]
" has('unix')         [Unix and Mac]
" has('macunix')      [Just mac]
" executable('racer') [Exectutable is found]

""" Go to line
" 42G
" 42gg
" :42<CR>
" 80%

""" VimDiff
" [c                  [Previous diff]
" ]c                  [Next diff]
" do                  [Diff obtain]
" dp                  [Diff put]

""" Surround
" s                   [Surround]
" cs                  [Change surround]
" ds                  [Delete surround]
" ys                  [Add surround]
