-- Hops through the jumplist while jumps are within the same file
-- TODO: Maybe keep a stack that gets populated on autocommand? This would work separately from the jumplist

local get_jumplist = function()
  local raw_jumplist = vim.fn.getjumplist()
  return raw_jumplist[1], raw_jumplist[2] + 1
end

local backward = function()
  local jumplist, last_jump = get_jumplist()

  if #jumplist == 0 then
    return false
  end

  local curr_index = last_jump > #jumplist and #jumplist or last_jump
  local curr_bufnr = vim.api.nvim_get_current_buf()

  while curr_index > 0 do
    local target_bufnr = jumplist[curr_index].bufnr
    if curr_bufnr ~= target_bufnr and vim.api.nvim_buf_is_loaded(target_bufnr) then
      vim.cmd('execute "normal! ' .. last_jump - curr_index .. [[\<c-o>"]])
      return true
    end
    curr_index = curr_index - 1
  end

  return false
end

local forward = function()
  local jumplist, last_jump = get_jumplist()

  if last_jump > #jumplist then
    return false
  end

  local curr_index = last_jump
  local curr_bufnr = vim.api.nvim_get_current_buf()

  while curr_index <= #jumplist do
    local target_bufnr = jumplist[curr_index].bufnr
    if curr_bufnr ~= target_bufnr and vim.api.nvim_buf_is_loaded(target_bufnr) then
      vim.cmd('execute "normal! ' .. curr_index - last_jump .. [[\<c-i>"]])
      return true
    end
    curr_index = curr_index + 1
  end

  return false
end

local delete = function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })

  if #bufs < 2 then
    vim.notify('Last loaded buffer', vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  if not backward() then
    for b in bufs do
      if b.bufnr ~= bufnr then
        vim.api.nvim_set_current_buf(b.bufnr)
      end
    end
    vim.notify('Seems like this is the last loaded buffer', vim.log.levels.WARN)
    return
  end
  vim.api.nvim_buf_delete(bufnr, {})
end

local map = require('script.helper').map

map('', '[b', '<cmd>lua require("plugin.buffer_stack").backward()<CR>')
map('', ']b', '<cmd>lua require("plugin.buffer_stack").forward()<CR>')
map('', '][b', '<cmd>lua require("plugin.buffer_stack").delete()<CR>')

return {
  backward = backward,
  forward = forward,
  delete = delete,
}