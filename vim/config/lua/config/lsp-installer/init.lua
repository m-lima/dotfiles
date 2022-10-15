local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

vim.api.nvim_create_user_command(
  'Slsp',
  function(args)
    local id = tonumber(args.args)
    if id then
      local client = vim.lsp.get_client_by_id(id)
      if client then
        for bufnr, _ in pairs(client.attached_buffers) do
          vim.api.nvim_del_augroup_by_name(string.format('lsp_c_%d_b_%d_did_save', id, bufnr))
          vim.api.nvim_del_augroup_by_name('pluginLsp_' .. client.name .. bufnr)
        end
      end
      vim.lsp.stop_client(id)
    else
      vim.notify('Expected a LSP client ID. Got: `' .. args.args .. '`', vim.log.levels.ERROR)
    end
  end,
  {
    desc = 'Stop a running LSP',
    nargs = 1,
  }
)

local make_on_attach = function(opts)
  return function(client, bufnr)

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
            callback = vim.lsp.buf.formatting_sync,
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
  end
end

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local on_attach_opts = {
      codelens = true,
      format = true,
      highlight = true,
      inlay = true,
      mapping = {
        error = true,
        hover = true,
        rename = true,
        run = true,
        telescope = true,
      },
    }

    local opts = {
      capabilities = cmp_capabilities,
      on_init = function(client)
        local root = client.config.root_dir or vim.fn.getcwd()
        if root then
          local ok, cfg = pcall(dofile, root .. '/.vim/lspconfig.lua')
          if ok then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, cfg)
            return true
          end
        end
      end
    }

    if server.name == 'rust_analyzer' then
      opts.on_attach = make_on_attach(on_attach_opts)
      require('config.lsp-installer.rust').prepare(opts)
      -- TODO: PR rust-tools with toggleterm config
      -- TODO: PR rust-tools with inlayTrigger
      -- TODO: PR rust-tools with new inlays
      -- TODO: PR rust-tools with module popup
    elseif server.name == 'sumneko_lua' then
      -- TODO: Do this only if working with vim files
      -- TODO: Not quite working.. The global is ok, but the inspection into library is not
      opts.settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
            path = vim.split(package.path, ';'),
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = {
              [vim.env.VIMRUNTIME .. '/lua'] = true,
              [vim.env.VIMRUNTIME .. '/lua/vim/lsp'] = true,
            },
          },
          telemetry = {
            enable = false,
          },
        }
      }
    elseif server.name == 'volar' then
      on_attach_opts.format = false
    elseif server.name == 'eslint' then
      on_attach_opts.format = 'EslintFixAll'
    end

    if not opts.on_attach then
      opts.on_attach = make_on_attach(on_attach_opts)
    end
    server:setup(opts)
  end
)
