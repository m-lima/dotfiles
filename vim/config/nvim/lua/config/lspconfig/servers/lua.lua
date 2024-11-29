local lua_ls = {
  features = {
    name = 'lua',
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
