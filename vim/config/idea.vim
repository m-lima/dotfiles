""""""""""""""""""""
" Idea config
""""""""""""""""""""

set surround
set commentary
set ReplaceWithRegister
" By making the bell be visual and having it disabled in options, it stops completely on Idea
set visualbell

map ]b         <Action>(Forward)
map [b         <Action>(Back)

map ]e         <Action>(GotoNextError)
map [e         <Action>(GotoPreviousError)

map ]g         <Action>(VcsShowNextChangeMarker)
map [g         <Action>(VcsShowPrevChangeMarker)

map <leader>n  <Action>(ActivateProjectToolWindow)
map <leader>p  <Action>(GotoFile)

map ?          <Action>(FindInPath)

map <C-q>      <Action>(ActivateTerminalToolWindow)

map <leader>gr <Action>(Vcs.RollbackChangedLines)
map <leader>gb <Action>(Annotate)

map ge         <Action>(FindUsages)
