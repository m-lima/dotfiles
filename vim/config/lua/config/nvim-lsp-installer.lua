require('rust-tools').setup({})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local clients = {}

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local opts = {
      capabilities = capabilities,
      on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[
          augroup pluginLsp
            autocmd! * <buffer>
            autocmd CursorHold                      <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved,InsertEnter         <buffer> silent! lua vim.lsp.buf.clear_references()
            autocmd BufEnter,CursorHold,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()
            autocmd BufWritePre                     <buffer> silent! lua vim.lsp.buf.formatting_sync()
          augroup END
        ]])
      end,
    }

    if server.name == 'rust_analyzer' then
      local auCmd = function(bufnr)
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd([[
            augroup pluginLsp
              autocmd! * <buffer>
              autocmd CursorHold                       <buffer> silent! lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved,InsertEnter          <buffer> silent! lua vim.lsp.buf.clear_references()
              autocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()
              autocmd BufWritePre                      <buffer> silent! lua vim.lsp.buf.formatting_sync()
              autocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua require('plugin.inlay').hints()
            augroup END
          ]])
          vim.lsp.codelens.refresh()
          require('plugin.inlay').hints()
        end)
      end

      opts.handlers = {
        ["experimental/serverStatus"] = function(err, res, ctx, _config)
          if not err and res.quiescent then
            local client_instance = clients[ctx.client_id]
            if client_instance then
              client_instance.done = true
              if client_instance.queue then
                for _, bufnr in ipairs(client_instance.queue) do
                  auCmd(bufnr)
                end
                client_instance = nil
              end
            else
              clients[ctx.client_id] = {
                done = true
              }
            end
          end
        end
      }

      opts.on_attach = function(client)
        local client_instance = clients[client.id]
        local bufnr = vim.api.nvim_get_current_buf()
        if client_instance then
          if client_instance.done then
            auCmd(bufnr)
          else
            table.insert(client_instance.queue, bufnr)
          end
        else
          clients[client.id] = {
            queue = { bufnr }
          }
        end
      end

      -- opts.settings = {
      --   -- TODO: Make this project specific
      --   ['rust-analyzer'] = {
      --     checkOnSave = {
      --       command = 'clippy',
      --       extraArgs = { '--', '-W', 'clippy::pedantic' },
      --     },
      --   },
      -- }
      -- TODO: PR upstream with toggleterm config
      -- TODO: PR upstream with inlayTrigger
      require('rust-tools').setup {
        server = vim.tbl_deep_extend('force', opts, server:get_default_options()),
        tools = {
          autoSetHints = false,
          -- inlay_hints = {
          --   show_variable_name = true,
          --   show_parameter_hints = false,
          --   parameter_hints_prefix = '',
          --   other_hints_prefix = '‣',
          --   highlight = 'LspCodeLens',
          -- },
          executor = require('config.toggleterm.extension.rust_tools'),
          hover_actions = {
            border = {},
            auto_focus = true,
          },
        },
      }
      server:attach_buffers()
      return
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
    end
    server:setup(opts)
end
)
