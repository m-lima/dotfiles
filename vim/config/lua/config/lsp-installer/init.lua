-- require('rust-tools').setup({})

local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local make_on_attach = function(opts)
  return function(client)
    local autocmd = ''
    if opts.codelens and client.resolved_capabilities.code_lens then
      autocmd = autocmd .. '\nautocmd BufEnter,CursorHold,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()'
    end
    if opts.format then
      if type(opts.format) == 'string' then
        autocmd = autocmd .. '\nautocmd BufWritePre                   <buffer> ' .. opts.format
      elseif client.resolved_capabilities.document_formatting then
        autocmd = autocmd .. '\nautocmd BufWritePre                   <buffer> silent! lua vim.lsp.buf.formatting_sync()'
      end
    end
    if opts.highlight and client.resolved_capabilities.document_highlight then
      autocmd = autocmd .. '\nautocmd CursorHold                      <buffer> silent! lua vim.lsp.buf.document_highlight()'
      autocmd = autocmd .. '\nautocmd CursorMoved,InsertEnter         <buffer> silent! lua vim.lsp.buf.clear_references()'
    end

    if #autocmd > 0 then
      autocmd = 'augroup pluginLsp_' .. client.name .. '\nautocmd! * <buffer>' .. autocmd .. '\naugroup END'
      vim.cmd(autocmd)
    end
  end
end

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local on_attach_opts = {
      codelens = true,
      format = true,
      highlight = true,
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
    }

    if server.name == 'rust_analyzer' then
      opts.on_attach = make_on_attach(on_attach_opts)
      require('config.lsp-installer.rust').prepare(opts)

      -- -- opts.settings = {
      -- --   -- TODO: Make this project specific
      -- --   ['rust-analyzer'] = {
      -- --     checkOnSave = {
      -- --       command = 'clippy',
      -- --       extraArgs = { '--', '-W', 'clippy::pedantic' },
      -- --     },
      -- --   },
      -- -- }
      -- -- TODO: PR upstream with toggleterm config
      -- -- TODO: PR upstream with inlayTrigger
      -- require('rust-tools').setup {
      --   server = vim.tbl_deep_extend('force', opts, server:get_default_options()),
      --   tools = {
      --     autoSetHints = false,
      --     -- inlay_hints = {
      --     --   show_variable_name = true,
      --     --   show_parameter_hints = false,
      --     --   parameter_hints_prefix = '',
      --     --   other_hints_prefix = '‣',
      --     --   highlight = 'LspCodeLens',
      --     -- },
      --     executor = require('config.toggleterm.extension.rust_tools'),
      --     hover_actions = {
      --       border = {},
      --       auto_focus = true,
      --     },
      --   },
      -- }
      -- server:attach_buffers()
      -- return
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
            globals = {'vim'},
          },
          workspace = {
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            },
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
end)
