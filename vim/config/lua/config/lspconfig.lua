local map = require('script.helper').map

map('n', ']e',                vim.diagnostic.goto_next)
map('n', '[e',                vim.diagnostic.goto_prev)
map('n', '<leader>d',         vim.lsp.buf.hover)
map('n', '<leader><leader>r', vim.lsp.buf.rename)
map('n', '<leader>r',         vim.lsp.codelens.run)
map('n', '<leader>a',         vim.lsp.buf.code_action)

vim.diagnostic.config({
  severity_sort = true,
  signs = false,
  underline = true,
})

vim.cmd([[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
  sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
  sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
  sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
]])

vim.api.nvim_create_user_command(
  'Slsp',
  function(args)
    local id = tonumber(args.args)
    if id then
      vim.lsp.stop_client(id)
    else
      vim.notify('Expected a LSP client ID. Got: `' .. args.args ..'`', vim.log.levels.ERROR)
    end
  end,
  {
    desc = 'Stop a running LSP',
    nargs = 1,
  }
)
