local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('nvim-lsp-installer').on_server_ready(
  function(server)
    local opts = {
      capabilities = capabilities,
    }
    if server.name == 'rust_analyzer' then
      opts.on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[
          augroup pluginLsp
            autocmd! * <buffer>
            autocmd CursorHold                       <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved,InsertEnter          <buffer> silent! lua vim.lsp.buf.clear_references()
            autocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()
            autocmd BufWritePre                      <buffer> silent! lua vim.lsp.buf.formatting_sync()
            autocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua require('plugins.inlay').hints()
          augroup END
        ]])
      end
    else
      opts.on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[
          augroup pluginLsp
            autocmd! * <buffer>
            autocmd CursorHold                       <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved,InsertEnter          <buffer> silent! lua vim.lsp.buf.clear_references()
            autocmd TextChanged,InsertLeave,BufEnter <buffer> silent! lua vim.lsp.codelens.refresh()
            autocmd BufWritePre                      <buffer> silent! lua vim.lsp.buf.formatting_sync()
          augroup END
        ]])
      end
    end
    server:setup(opts)
end
)
