local lua_ls = {
  features = {
    name = 'lua',
  },
  root_markers = {
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
}

require('config.lspconfig.register').register('lua_ls', lua_ls)
