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
