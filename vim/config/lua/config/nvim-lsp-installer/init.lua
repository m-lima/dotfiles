-- local lsp_installer = require('nvim-lsp-installer')

-- lsp_installer.on_server_ready(
--   function(server)
--     local opts = {}

--     if server.name == "rust_analyzer" then
--       -- Initialize the LSP via rust-tools instead
--       require("rust-tools").setup {
--         -- The "server" property provided in rust-tools setup function are the
--         -- settings rust-tools will provide to lspconfig during init.            -- 
--         -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
--         -- with the user's own settings (opts).
--         server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
--       }
--       server:attach_buffers()
--     else
--       server:setup(opts)
--     end
--   end
-- )
local lsp_installer = require('nvim-lsp-installer')
-- local lsp_status = require('lsp-status')

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
lsp_installer.on_server_ready(
  function(server)
    local opts = {
      -- on_attach = lsp_status.on_attach,
      -- capabilities = lsp_status.capabilities,
      on_attach = function()
        vim.cmd([[autocmd! BufEnter,CursorHold,CursorHoldI,InsertLeave <buffer> silent! lua vim.lsp.codelens.refresh()]])
      end
    }

    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function will take the provided server configuration and decorate it with the necessary properties
    -- before passing it onwards to lspconfig.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end
)
