require('git-conflict').setup({
  disable_diagnostics = true,
  highlights = {
    ancestor = 'GitConflictAncestorBase',
    current = 'GitConflictCurrentBase',
    incoming = 'GitConflictIncomingBase',
  },
})
