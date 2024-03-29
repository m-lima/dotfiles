local dap = require('dap')

local dapui_instance = nil
local dapui = function()
  if not dapui_instance then
    dapui_instance = require("dapui")
    dapui_instance.setup({
      icons = { expanded = "", collapsed = "▶", current_frame = "▶" },
    })
  end
  return dapui_instance
end

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui().open()
end
-- dap.listeners.before.event_terminated['dapui_config'] = function()
--   dapui().close()
-- end
-- dap.listeners.before.event_exited['dapui_config'] = function()
--   dapui().close()
-- end

vim.api.nvim_create_user_command(
  'DapToggle',
  function()
    dapui().toggle()
  end,
  {
    desc = 'Toggle DAP GUI',
    nargs = 0,
  }
)

require('util').map('n', '<F12>', function() dapui().toggle() end)
