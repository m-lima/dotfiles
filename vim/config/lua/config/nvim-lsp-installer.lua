local lsp_installer = require('nvim-lsp-installer')

lsp_installer.on_server_ready(
  function(server)
    local opts = {
      on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[
          augroup pluginLsp
            autocmd!
            autocmd CursorHold  <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorHoldI <buffer> silent! lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> silent! lua vim.lsp.buf.clear_references()
            autocmd BufEnter,CursorHold,CursorHoldI,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()
          augroup END
        ]])
      end
    }
    server:setup(opts)
end
)
