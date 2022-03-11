-- require('rust-tools').setup({})

local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local opts = {
      capabilities = cmp_capabilities,
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
    end
    server:setup(opts)
end
)
