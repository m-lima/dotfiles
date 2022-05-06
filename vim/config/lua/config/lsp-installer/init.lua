local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local make_on_attach = function(opts)
  return function(client, bufnr)

    local augroupnr = nil
    local augroup = function()
      if not augroupnr then
        augroupnr = vim.api.nvim_create_augroup('pluginLsp_' .. client.name .. bufnr, { clear = true })
      end
      return augroupnr
    end

    if opts.codelens and client.resolved_capabilities.code_lens then
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
      elseif client.resolved_capabilities.document_formatting then
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

    if opts.highlight and client.resolved_capabilities.document_highlight then
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
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
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
