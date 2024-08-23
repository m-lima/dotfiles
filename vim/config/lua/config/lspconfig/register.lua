local lspconfig = require('lspconfig')
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local run_one_shot = function(server, one_shot)
  if one_shot then
    if type(one_shot) == 'function' then
      one_shot()
    else
      vim.notify('Field `one_shot` is not a function for ' .. server, vim.log.levels.WARN)
    end
  end
end

local defer_tracking = {}

local defer = function(server, opts)
  if not opts.handlers then
    opts.handlers = {}
  end

  local on_attach = opts.on_attach
  local deferred_attach = function(client, bufnr)
    vim.api.nvim_buf_call(bufnr, function() on_attach(client, bufnr) end)
  end

  opts.handlers = {
    ['experimental/serverStatus'] = function(err, res, ctx)
      if not err and res.quiescent then
        local tracked_instance = defer_tracking[ctx.client_id]
        run_one_shot(server, opts.one_shot)
        if tracked_instance then
          tracked_instance.done = true
          if tracked_instance.queue then
            local tracked_client = vim.lsp.get_client_by_id(ctx.client_id)
            for _, bufnr in ipairs(tracked_instance.queue) do
              deferred_attach(tracked_client, bufnr)
            end
          end
        else
          defer_tracking[ctx.client_id] = {
            done = true
          }
        end
      end
    end
  }

  opts.on_attach = function(client, bufnr)
    local tracked_instance = defer_tracking[client.id]
    if tracked_instance then
      if tracked_instance.done then
        deferred_attach(client, bufnr)
      else
        table.insert(tracked_instance.queue, bufnr)
      end
    else
      defer_tracking[client.id] = {
        queue = { bufnr }
      }
    end
  end

  opts.capabilities = vim.tbl_deep_extend('force', { experimental = { serverStatusNotification = true } },
    opts.capabilities or {})

  return opts
end

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
      vim.tbl_deep_extend(
        'force',
        client.features_override or {},
        overrides or {}
      )
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
      vim.api.nvim_buf_attach(
        bufnr,
        false,
        {
          on_lines = function()
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
        cfg = cfg(server)
      end
      if type(cfg) == 'table' and cfg[server] ~= nil then
        return cfg[server], maybe_config
      end
    end
  end
end

local make_on_init = function(server)
  return function(client)
    local cfg, path = search_for_config(vim.fn.expand('%:p'), server)
    if cfg then
      local overriden = false
      if cfg.settings ~= nil then
        vim.notify('Loaded settings override from ' .. path .. ' for ' .. server)
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, cfg.settings)
        overriden = true
      end
      if cfg.features ~= nil then
        vim.notify('Loaded features override from ' .. path .. ' for ' .. server)
        client.features_override = cfg.features
        overriden = true
      end
      return overriden
    end
  end
end

local base_opts = function(server, opts)
  return vim.tbl_deep_extend('force', {
    capabilities = cmp_capabilities,
    on_attach = make_on_attach(opts and opts.features),
    on_init = make_on_init(server),
  }, opts or {})
end

return function(server, opts, defer_init)
  opts = base_opts(server, opts)
  if defer_init then
    opts = defer(server, opts)
  else
    run_one_shot(server, opts.one_shot)
  end
  lspconfig[server].setup(opts)
end
