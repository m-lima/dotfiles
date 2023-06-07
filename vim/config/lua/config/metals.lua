local config = require('metals').bare_config()

config.settings = {
  showImplicitArguments = true,
}
config.init_options.statusBarProvider = 'on'
config.capabilities = require('cmp_nvim_lsp').default_capabilities()
config.on_attach = function(client, bufnr)
  require('metals').setup_dap()

  local augroup = vim.api.nvim_create_augroup('pluginLsp_' .. client.name .. bufnr, { clear = true })

  -- Codelens
  vim.api.nvim_create_autocmd(
    {
      'BufEnter',
      'CursorHold',
      'InsertLeave',
    },
    {
      desc = 'Refresh codelens',
      group = augroup,
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    }
  )
  vim.lsp.codelens.refresh()

  -- Highlighting
  vim.api.nvim_create_autocmd(
    'CursorHold',
    {
      desc = 'Highlight symbol',
      group = augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    }
  )
  vim.api.nvim_create_autocmd(
    {
      'CursorMoved',
      'InsertEnter',
    },
    {
      desc = 'Clear symbol highlight',
      group = augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    }
  )

  -- Formatting
  vim.api.nvim_create_autocmd(
    'BufWritePre',
    {
      desc = 'Format code',
      group = augroup,
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end,
    }
  )
end

-- TODO: Move this to the DAP initializer
require('dap').configurations.scala = {
  {
    type = 'scala',
    request = 'launch',
    name = 'Run or Test',
    metals = {
      runType = 'runOrTestFile',
      args = function()
        return require('util').parse_args(vim.fn.input('Args: '))
      end,
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = 'Test Target',
    metals = {
      runType = 'testTarget',
    },
  }
}

local metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = {
      'scala',
      'sbt',
    },
    desc = 'Start or attach metals',
    callback = function()
      require('metals').initialize_or_attach(config)
    end,
    group = metals_group,
  }
)
