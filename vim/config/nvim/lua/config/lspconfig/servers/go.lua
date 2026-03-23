local gopls = {
  settings = {
    gopls = {
      gofumpt = true
    },
  },
}

local golang_lint = {
  cmd = { 'golangci-lint-langserver' },
  root_markers = { '.git', 'go.mod' },
  init_options = {
    command = {
      'golangci-lint',
      'run',
      '--output.json.path',
      'stdout',
      '--show-stats=false',
      '--issues-exit-code=1',
    },
  },
}

local register = require('config.lspconfig.register').register
register('gopls', gopls)
register('golangci_lint_ls', golang_lint)
