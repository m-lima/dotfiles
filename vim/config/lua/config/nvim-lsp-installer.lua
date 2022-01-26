local lsp_installer = require('nvim-lsp-installer')

lsp_installer.on_server_ready(
  function(server)
    local opts = {
      on_attach = function()
        -- TODO: Update this when the API for autocmd stabilizes
        vim.cmd([[autocmd! BufEnter,CursorHold,CursorHoldI,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()]])
      end
    }
    server:setup(opts)
end
)
