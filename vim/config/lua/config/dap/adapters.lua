local dap = require('dap')

local M = {}

M.codelldb = function()
  dap.adapters.codelldb = function(on_adapter)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local cmd = os.getenv('HOME') .. '/code/utils/codelldb/extension/adapter/codelldb'

    local handle, pid_or_err
    local opts = {
      stdio = { nil, stdout, stderr },
      detached = true,
    }
    handle, pid_or_err = vim.loop.spawn(cmd, opts, function(code)
      stdout:close()
      stderr:close()
      handle:close()
      if code ~= 0 then
        print('codelldb exited with code', code)
      end
    end)

    assert(handle, 'Error running codelldb: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        local port = chunk:match('Listening on port (%d+)')
        if port then
          vim.schedule(function()
            on_adapter({
              type = 'server',
              host = '127.0.0.1',
              port = port
            })
          end)
        else
          vim.schedule(function()
            require('dap.repl').append(chunk)
          end)
        end
      end
    end)

    stderr:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
  end

  dap.configurations.rust = { {
    name = 'Launch',
    type = 'codelldb',
    request = 'launch',
    program = function()
      local executables = {}

      if vim.fn.filereadable('Cargo.toml') == 1 then
        print('Building workspace..')
        local build_output = vim.fn.system('cargo build --workspace --message-format=json')
        for line in build_output:gmatch('[^\r\n]+') do
          local ok, json = pcall(vim.fn.json_decode, line)
          if ok then
            if type(json) == 'table' and json.executable ~= vim.NIL and json.executable ~= nil then
              table.insert(executables, json.executable)
            end
          end
        end
      end

      if #executables > 0 then
        local options = { '0. Manual' }
        for i, v in ipairs(executables) do
          table.insert(options, i .. '. ' .. v)
        end
        local option = vim.fn.inputlist(options)
        if option > 0 then
          return executables[option]
        end
      end

      local cargo_target = os.getenv('CARGO_TARGET_DIR')
      if cargo_target then
        return vim.fn.input('Path to executable: ', cargo_target .. '/debug/', 'file')
      else
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
      end
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      local str = vim.fn.input('Args: ')
      local args = {}
      for a in string.gmatch(str, '([^ ]+)') do
        table.insert(args, a)
      end
      return args
    end,
    runInTerminal = false,
  } }
  dap.configurations.c = dap.configurations.rust
  dap.configurations.cpp = dap.configurations.rust
end

-- M.lldb = function()
--   dap.adapters.lldb = {
--     name = 'lldb',
--     type = 'executable',
--     command = '/opt/homebrew/Cellar/llvm/13.0.1/bin/lldb-vscode',
--     -- type = 'server',
--     -- host = '127.0.0.1',
--     -- port = 58183,
--   }
--   dap.configurations.rust = {{
--     name = 'Launch',
--     type = 'lldb',
--     request = 'launch',
--     -- TODO: Grab from rust
--     -- TODO: List on telescope
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopOnEntry = false,
--     args = {},
--
--     -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
--     --
--     --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
--     --
--     -- Otherwise you might get the following error:
--     --
--     --    Error on launch: Failed to attach to the target process
--     --
--     -- But you should be aware of the implications:
--     -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
--     runInTerminal = false,
--   }}
--   dap.configurations.c = dap.configurations.rust
--   dap.configurations.cpp = dap.configurations.rust
-- end
--
-- M.cpptools = function()
--   dap.adapters.cppdbg = {
--     id = 'cppdbg',
--     type = 'executable',
--     command = '/Users/celo/code/utils/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
--   }
--   dap.configurations.rust = {
--     {
--       name = 'Launch file',
--       type = 'cppdbg',
--       request = 'launch',
--       program = function()
--         return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--       end,
--       cwd = '${workspaceFolder}',
--       stopOnEntry = true,
--     },
--   }
--   dap.configurations.c = dap.configurations.rust
--   dap.configurations.cpp = dap.configurations.rust
-- end

return M
