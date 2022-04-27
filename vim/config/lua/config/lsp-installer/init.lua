local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- TODO: Update to nvim 0.7 vim.api.nvim_create_autocmd
local make_on_attach = function(opts)
  return function(client)
    local autocmd = ''
    if opts.codelens and client.resolved_capabilities.code_lens then
      autocmd = autocmd .. '\nautocmd BufEnter,CursorHold,InsertLeave  <buffer> silent! lua vim.lsp.codelens.refresh()'
      vim.lsp.codelens.refresh()
    end
    if opts.format then
      if type(opts.format) == 'string' then
        autocmd = autocmd .. '\nautocmd BufWritePre                    <buffer> ' .. opts.format
      elseif client.resolved_capabilities.document_formatting then
        autocmd = autocmd .. '\nautocmd BufWritePre                    <buffer> silent! lua vim.lsp.buf.formatting_sync()'
      end
    end
    if opts.highlight and client.resolved_capabilities.document_highlight then
      autocmd = autocmd .. '\nautocmd CursorHold                       <buffer> silent! lua vim.lsp.buf.document_highlight()'
      autocmd = autocmd .. '\nautocmd CursorMoved,InsertEnter          <buffer> silent! lua vim.lsp.buf.clear_references()'
    end
    if opts.inlay and client.server_capabilities.experimental and client.server_capabilities.experimental.inlayHints then
      autocmd = autocmd .. '\nautocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua require("plugin.inlay").refresh()'
      require('plugin.inlay').refresh()
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
