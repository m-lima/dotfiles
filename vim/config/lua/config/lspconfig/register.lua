local lspconfig = require('lspconfig')
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local make_on_attach = function(overrides)
  return function(client, bufnr)
    local opts = vim.tbl_deep_extend(
      'force',
      {
        codelens = true,
        format = true,
        highlight = true,
        inlay = true,
        extra = nil,
      },
      overrides or {}
    )

    local augroupnr = nil
    local augroup = function()
      if not augroupnr then
        augroupnr = vim.api.nvim_create_augroup('pluginLsp_' .. client.name .. bufnr, { clear = true })
      end
      return augroupnr
    end

    if opts.codelens and client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd(
        {
          'BufEnter',
          'CursorHold',
          'InsertLeave',
        },
        {
          desc = 'Refresh codelens',
          group = augroup(),
          buffer = bufnr,
          callback = vim.lsp.codelens.refresh,
        }
      )
      vim.lsp.codelens.refresh()
    end

    if opts.format then
      if type(opts.format) == 'string' then
        vim.api.nvim_create_autocmd(
          'BufWritePre',
          {
            desc = 'Format code',
            group = augroup(),
            buffer = bufnr,
            command = opts.format,
          }
        )
      elseif type(opts.format) == 'function' then
        vim.api.nvim_create_autocmd(
          'BufWritePre',
          {
            desc = 'Format code',
            group = augroup(),
            buffer = bufnr,
            callback = opts.format,
          }
        )
      elseif client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd(
          'BufWritePre',
          {
            desc = 'Format code',
            group = augroup(),
            buffer = bufnr,
            callback = function() vim.lsp.buf.format() end,
          }
        )
      end
    end

    if opts.highlight and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd(
        'CursorHold',
        {
          desc = 'Highlight symbol',
          group = augroup(),
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
          group = augroup(),
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        }
      )
    end

    if opts.inlay and client.server_capabilities.inlayHintProvider then
      vim.api.nvim_create_autocmd(
        {
          'BufEnter',
          'TextChanged',
          'InsertLeave',
        },
        {
          desc = 'Display inlay hints',
          group = augroup(),
          buffer = bufnr,
          callback = function()
            require('plugin.inlay').refresh()
          end,
        }
      )
      require('plugin.inlay').refresh()
    end

    if opts.extra then
      if type(opts.extra) == 'function' then
        opts.extra(client, bufnr)
      else
        vim.notify('Field `extra` is not a function for `on_attach`', vim.log.levels.WARN)
      end
    end
  end
end

local path_separator = '/'
if vim.fn.has('win32') == 1 or vim.fn.has('win32unix') == 1 then
  path_separator = '\\'
end
local lspconfig_file = path_separator .. '.vim' .. path_separator .. 'lspconfig.lua'

local search_for_config = function(path, server)
  while path ~= path_separator and #path > 0 do
    path = string.gsub(path, '^(.*)' .. path_separator .. '.+$', '%1')
    local maybe_config = path .. lspconfig_file
    local ok, cfg = pcall(dofile, maybe_config)
    if ok then
      if type(cfg) == 'function' then
        return cfg(server), maybe_config
      else
        return cfg, maybe_config
      end
    end
  end
end

local make_on_init = function(server)
  return function(client)
    local cfg, path = search_for_config(vim.fn.expand('%:p'), server)
    if cfg then
      vim.notify('Loaded override from ' .. path)
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, cfg)
      return true
    end
  end
end

local base_opts = function(server, opts)
  return {
    capabilities = cmp_capabilities,
    on_attach = make_on_attach(opts and opts.features),
    on_init = make_on_init(server),
    settings = opts and opts.settings,
  }
end

return function(server, opts)
  lspconfig[server].setup(base_opts(server, opts))

  if opts and opts.one_shot then
    if type(opts.one_shot) == 'function' then
      opts.one_shot()
    else
      vim.notify('Field `one_shot` is not a function for ' .. server, vim.log.levels.WARN)
    end
  end
end
