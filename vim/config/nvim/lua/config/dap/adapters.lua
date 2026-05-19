local dap = require('dap')

local codelldb = function()
  dap.adapters.codelldb = {
    type = 'server',
    port = '58525',
    executable = {
      command = 'codelldb',
      args = { '--port', '58525' },
    },
  }

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
        local routine = coroutine.running()

        vim.ui.select(
          executables,
          {
            prompt = 'Select executable:',
          },
          function(choice)
            coroutine.resume(routine, choice)
          end
        )

        local option = coroutine.yield()
        if option then
          return option
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
      return require('util').parse_args(vim.fn.input('Args: '))
    end,
    runInTerminal = false,
  } }

  dap.configurations.zig = { {
    name = 'Debug',
    type = 'codelldb',
    request = 'launch',
    program = function()
      print('Zig DAP: Printing paths..')
      local routine = coroutine.running()

      local output = {}
      local executables = {}
      local option = nil

      local ok, err = pcall(
        vim.fn.jobstart,
        { 'zig', 'build', 'print-path' },
        {
          on_stderr = function(pid, stderr)
            for _, v in ipairs(stderr) do
              table.insert(output, v)
            end
          end,
          on_exit = function(pid, status)
            coroutine.resume(routine, status == 0)
          end
        }
      )

      if not ok then
        if err then vim.notify(err, vim.log.levels.WARN) end
        goto bail
      end

      ok = coroutine.yield();

      if not output or #output == 0 then
        goto bail
      end

      if not ok then
        for _, err in ipairs(output) do vim.notify(err, vim.log.levels.WARN) end
        goto bail
      end

      for _, line in ipairs(output) do
        if line and #line > 0 then
          local name = vim.fs.basename(line)
          for i, v in ipairs(executables) do
            if v == name then
              executables[i][1] = executables[i][2]
              name = line
              break
            end
          end
          table.insert(executables, {name, line})
        end
      end

      if #executables == 0 then
        goto bail
      end

      vim.ui.select(
        executables,
        {
          prompt = 'Select executable:',
          format_item = function(item)
            return item[1]
          end,
        },
        function(choice)
          coroutine.resume(routine, choice and choice[2])
        end
      )

      option = coroutine.yield()
      if option then
        return option
      end

      ::bail::
      return vim.fn.input('Path to executable: ', vim.fn.getcwd(), 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      return require('util').parse_args(vim.fn.input('Args: '))
    end,
    runInTerminal = false,
  } }

  dap.configurations.c = dap.configurations.rust
  dap.configurations.cpp = dap.configurations.rust
end

local python = function()
  local python_path = vim.fn.exepath('python3')
  if python_path then
    dap.adapters.python = {
      type = 'executable',
      command = python_path,
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    }

    dap.configurations.python = { {
      name = 'Python',
      type = 'python',
      request = 'launch',
      program = vim.fn.bufname,
    } }
  end
end

return {
  codelldb = codelldb,
  python = python,
}
