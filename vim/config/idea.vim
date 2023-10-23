""""""""""""""""""""
" Idea config
""""""""""""""""""""

" Get actions from `IdeaVim: Track Action Ids`

set surround
set commentary
set ReplaceWithRegister
set highlightedyank

" By making the bell be visual and having it disabled in options, it stops completely on Idea
set visualbell

" Not really the behavior of BufferStack
map ]b         <Action>(Forward)
map [b         <Action>(Back)
map ][b        <Action>(CloseContent)

map ]e         <Action>(GotoNextError)
map [e         <Action>(GotoPreviousError)

map ]g         <Action>(VcsShowNextChangeMarker)
map [g         <Action>(VcsShowPrevChangeMarker)

map <leader>n  <Action>(ActivateProjectToolWindow)
map <leader>p  <Action>(GotoFile)

map ?          <Action>(FindInPath)

" Can this be a toggle?
" Seems like it IS a toggle, but with the focus being on the terminal, the
" `<C-q>` doesn't get captured
map <C-q>      <Action>(ActivateTerminalToolWindow)

" Missing `gs`
map <leader>gr <Action>(Vcs.RollbackChangedLines)
map <leader>gb <Action>(Annotate)

map ge         <Action>(FindUsages)
