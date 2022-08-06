vim.api.nvim_create_user_command(
  'LuaOut',
  'lua require("util").float.show(<args>)',
  {
    desc = 'Display lua output as a floating window',
    nargs = 1,
  }
)
