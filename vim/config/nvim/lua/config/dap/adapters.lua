local dap = require('dap')

local getcwd = function(name)
    local lsps = vim.lsp.get_clients({ bufnr = bufnr, name = name })
    return (lsps and lsps[1] and lsps[1].root_dir) or vim.fn.getcwd()
end

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
    name = 'Debug',
    type = 'codelldb',
    request = 'launch',
    program = function()
      print('Rust DAP: Building workspace..')
      local routine = coroutine.running()

      local output = {}
      local executables = {}
      local option = nil

      local cwd = getcwd('rust_analyzer')

      local ok, err = pcall(
        vim.fn.jobstart,
        { 'cargo', 'build', '--workspace', '--message-format=json' },
        {
          cwd = cwd,
          on_stdout = function(pid, stdout)
            for _, v in ipairs(stdout) do
              table.insert(output, {v, false})
            end
          end,
          on_stderr = function(pid, stderr)
            for _, v in ipairs(stderr) do
              table.insert(output, {v, true})
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
        for _, err in ipairs(output) do
          if err[2] then vim.notify(err[1], vim.log.levels.WARN) end
        end
        goto bail
      end

      for _, line in ipairs(output) do
        if line[2] then goto nextline end
        local ok, json = pcall(vim.fn.json_decode, line[1])
        if ok then
          if type(json) == 'table' and json.executable ~= vim.NIL and json.executable ~= nil then
            local name = vim.fs.basename(json.executable)
            for i, v in ipairs(executables) do
              if v == name then
                executables[i][1] = executables[i][2]
                name = json.executable
                break
              end
            end
            table.insert(executables, {name, json.executable})
          end
        end
        ::nextline::
      end

      if #executables == 0 then
        goto bail
      end

      vim.ui.select(
        executables,
        {
          prompt = 'Select executable:',
          format_item = function(item) return item[1] end,
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
      local cargo_target = os.getenv('CARGO_TARGET_DIR') or cwd
      return vim.fn.input('Path to executable: ', cargo_target .. '/target/debug/', 'file')
    end,
    cwd = function() return getcwd('rust_analyzer') end,
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

      local cwd = getcwd('zls')

      local ok, err = pcall(
        vim.fn.jobstart,
        { 'zig', 'build', 'print-path' },
        {
          cwd = cwd,
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
          format_item = function(item) return item[1] end,
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
      return vim.fn.input('Path to executable: ', cwd, 'file')
    end,
    cwd = function() return getcwd('zls') end,
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
