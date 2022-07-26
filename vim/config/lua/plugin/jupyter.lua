local path = vim.fn.expand('$HOME/code/python/env/jupyter/bin/')

if vim.fn.executable(path .. 'jupyter') == 0 then
  return;
end

local initialized = false

local initialize = function()
  if not initialized then
    local activation = '"' .. path .. 'activate_this.py"'
    local command = 'pythonx with open(' .. activation .. ') as f: exec(f.read(), {"__file__": ' .. activation .. '})'
    local ok, result = pcall(vim.cmd, command)

    if ok then
      initialized = true
    else
      vim.notify('Could not load virtual environment for Jupyter', vim.log.levels.WARN)
      for _, line in ipairs(vim.split(result, '\n')) do
        vim.notify(line, vim.log.levels.ERROR)
      end
    end
  end

  return initialized
end

local start = function()
  if initialize() then
    local jupyter = require('config.toggleterm.extension').run(path .. 'jupyter console')

    if not jupyter:is_open() then
      jupyter:open(nil, 'vertical')
      vim.cmd('stopinsert')
      vim.cmd('wincmd p')
    end

    if vim.fn.exists(':JupyterConnect') == 2 then
      local connect = vim.fn.input('Connect? [y/N] ')
      if connect == 'y' then
        vim.cmd('JupyterConnect')
      end
    end
  end
end

vim.api.nvim_create_user_command(
  'StartJupyter',
  start,
  {
    desc = 'Load and start jupyter',
  }
)
