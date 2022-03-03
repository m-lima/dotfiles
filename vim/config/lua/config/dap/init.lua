require('dap')
require('config.dap.adapters').codelldb()

local map = require('script.helper').map
map('n', '<F2>',  '<cmd>lua require("dap").toggle_breakpoint()<CR>')
map('n', '<F3>',  '<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
map('n', '<F4>',  '<cmd>lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
map('n', '<F5>',  '<cmd>lua require("dap").continue()<CR>')
map('n', '<F6>',  '<cmd>lua require("dap").run_last()<CR>')
map('n', '<F7>',  '<cmd>lua require("dap").step_into()<CR>')
map('n', '<F8>',  '<cmd>lua require("dap").step_over()<CR>')
map('n', '<F9>',  '<cmd>lua require("dap").step_out()<CR>')
map('n', '<F10>', '<cmd>lua require("dap").repl.open()<CR>')

vim.cmd([[
  sign define DapBreakpoint          text=●  texthl=DiagnosticError linehl= numhl=
  sign define DapBreakpointCondition text=◆  texthl=DiagnosticError linehl= numhl=
  sign define DapBreakpointRejected  text=◌  texthl=DiagnosticError linehl= numhl=
  sign define DapLogPoint            text=▶  texthl=DiagnosticInfo  linehl= numhl=
  sign define DapStopped             text=→  texthl=DiagnosticInfo  linehl= numhl=
]])
