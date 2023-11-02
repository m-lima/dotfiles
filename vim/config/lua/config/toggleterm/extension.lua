local M = {}

M.ids = {}

M.run = function(cmd, id, no_toggle)
  if not id then
    if M.ids[cmd] then
      id = M.ids[cmd]
    else
      id = math.random(200, 999)
      M.ids[cmd] = id
    end
  end

  local opts = {
    id = id,
    cmd = cmd,
    direction = 'float',
    hidden = true,
  }
  if not no_toggle then
    opts.on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<C-q>', '<cmd>close<CR>', { noremap = true, silent = true })
    end
  end
  return require('toggleterm.terminal').Terminal:new(opts)
end

M.lazygit = function()
  return M.run('lazygit', 100)
end

M.evcxr = function()
  return M.run('evcxr', 101)
end

M.luajit = function()
  return M.run('luajit', 102)
end

M.node = function()
  return M.run('node', 103)
end

M.python = function()
  return M.run('python', 104)
end

M.runner = function(cmd, cwd)
  local t, new = require('toggleterm.terminal').get_or_create_term(109)

  if cwd then
    cmd = '(cd ' .. cwd .. ' && ' .. cmd .. ')'
  end
  cmd = '\x15' .. cmd

  if t:is_open() then
    t:close()
  end
  t:toggle(nil, 'float')

  t:send(cmd, false)

  if not new then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)
  end
end

-- function M.execute_command(cmd, cwd)
--   cmd = 'echo "' .. cmd .. '" && ' .. cmd
--   return require('toggleterm.terminal').Terminal:new({
--     dir = cwd,
--     cmd = cmd,
--     close_on_exit = false,
--     direction = 'float',
--     on_open = function(term)
--       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true), "", true)
--       vim.api.nvim_buf_set_keymap(term.bufnr, '', '<C-q>', '<cmd>close<CR>', { noremap = true, silent = true })
--       vim.api.nvim_buf_set_keymap(term.bufnr, '', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
--     end,
--   }):toggle()
-- end

return M
