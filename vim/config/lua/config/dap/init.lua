local dap = require('dap')
require('config.dap.adapters').codelldb()

local map = require('util').map
map('n', '<F2>',  dap.toggle_breakpoint)
map('n', '<F3>',  function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
map('n', '<F4>',  function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end)
map('n', '<F5>',  dap.continue)
map('n', '<F6>',  dap.run_last)
map('n', '<F7>',  dap.step_into)
map('n', '<F8>',  dap.step_over)
map('n', '<F9>',  dap.step_out)
map('n', '<F10>', dap.terminate)
map('n', '<F11>', dap.repl.open)

vim.cmd([[
  sign define DapBreakpoint          text=● texthl=DiagnosticError linehl= numhl=DiagnosticError
  sign define DapBreakpointCondition text=◆ texthl=DiagnosticError linehl= numhl=DiagnosticError
  sign define DapBreakpointRejected  text=◌ texthl=DiagnosticError linehl= numhl=DiagnosticError
  sign define DapLogPoint            text=▶ texthl=DiagnosticInfo  linehl= numhl=DiagnosticInfo
  sign define DapStopped             text=→ texthl=DiagnosticInfo  linehl= numhl=
]])
