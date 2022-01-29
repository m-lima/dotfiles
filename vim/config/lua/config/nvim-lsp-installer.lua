local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local opts = {
      capabilities = capabilities,
      on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[
          augroup pluginLsp
            autocmd!
            autocmd CursorHold  <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved,InsertEnter <buffer> silent! lua vim.lsp.buf.clear_references()
            autocmd TextChanged,InsertLeave,BufEnter <buffer> silent! lua vim.lsp.codelens.refresh()
          augroup END
        ]])
      end
    }
    server:setup(opts)
end
)
