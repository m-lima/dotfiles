local function map(mode, key, action, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.api.nvim_set_keymap(mode, key, action, opts)
end

local function map_check(mode, key, action, opts)
  local params = '"' .. key .. '","' .. mode .. '"'
  local previous = vim.api.nvim_eval('maparg(' .. params .. ')')
  if previous and previous ~= '' then
    vim.notify('Mapping prefix conflict for ' .. params .. '\nNew: ' .. action .. '\nOld: ' .. previous, vim.log.levels.ERROR)
  end

  previous = vim.api.nvim_eval('mapcheck(' .. params .. ')')
  if previous and previous ~= '' then
    vim.notify('Mapping prefix conflict for ' .. params .. '\nNew: ' .. action .. '\nOld: ' .. previous, vim.log.levels.WARN)
  end

  map(mode, key, action, opts)
end

return {
  map = map,
  map_check = map_check,
}
