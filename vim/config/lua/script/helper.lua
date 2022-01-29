local M = {}

local function map_override(mode, key, action, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.api.nvim_set_keymap(mode, key, action, opts)
end

local function map_check(mode, key, action, opts)
  local params = '"' .. key .. '","' .. mode .. '"'
  local previous = vim.api.nvim_eval('maparg(' .. params .. ')')
  if previous  and not previous == '' then
    return error('Mapping conflict for ' .. params .. ' -> ' .. previous)
  end

  previous = vim.api.nvim_eval('mapcheck(' .. params .. ')')
  if previous  and not previous == '' then
    return error('Mapping prefix conflict for ' .. params .. ' -> ' .. previous)
  end

  map_override(mode, key, action, opts)
end

-- TODO: Remove check once done with edits
M.map = map_check
M.hi = vim.highlight

return M
