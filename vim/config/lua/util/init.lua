local function map(mode, key, action, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, key, action, opts)
end

local function map_check(mode, key, action, opts)
  local params = '"' .. key .. '","' .. mode .. '"'
  local previous = vim.api.nvim_eval('maparg(' .. params .. ')')
  if previous and previous ~= '' then
    vim.notify('Mapping prefix conflict for ' .. params .. '\nNew: ' .. action .. '\nOld: ' .. previous,
      vim.log.levels.ERROR)
  end

  previous = vim.api.nvim_eval('mapcheck(' .. params .. ')')
  if previous and previous ~= '' then
    vim.notify('Mapping prefix conflict for ' .. params .. '\nNew: ' .. action .. '\nOld: ' .. previous,
      vim.log.levels.WARN)
  end

  map(mode, key, action, opts)
end

local function extract_color(name, default, background)
  if vim.fn.hlexists(name) == 0 then
    return default
  end

  local color = vim.api.nvim_get_hl_by_name(name, true)
  local ref = background and color.background or color.foreground
  if ref then
    return string.format('#%06x', ref)
  end

  return default
end

local mod = {}

mod.list = function(name)
  for k, _ in pairs(package.loaded) do
    if string.match(k, name) then
      print('Found "' .. k .. '"')
    end
  end
end

mod.unload = function(name)
  if package.loaded[name] then
    package.loaded[name] = nil
    print('Unloaded "' .. name .. '"')
    return true
  else
    print('Package "' .. name .. '" is not loaded')
    return false
  end
end

mod.reload = function(name)
  if mod.unload(name) then
    require(name)
    print('Reloaded "' .. name .. '"')
  end
end

local float = {}

float.show_raw = function(str, ft)
  local lines = {}
  for line in str:gmatch('([^\n]+)') do
    table.insert(lines, line)
  end

  local width = vim.api.nvim_get_option('columns')
  local height = vim.api.nvim_get_option('lines')

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local target = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(target, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_keymap(target, '', '<Esc>', '<cmd>q!<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_option(target, 'filetype', ft)
  vim.api.nvim_buf_set_lines(target, 0, #lines, false, lines)
  vim.api.nvim_buf_set_option(target, 'readonly', true)

  vim.api.nvim_open_win(target, true, {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
  })
end

float.show = function(cmd)
  local str = vim.inspect(cmd)

  float.show_raw(str, 'lua')
end

local function parse_args(str)
  if not str then return {} end

  local output = {}
  local accumulator = ''
  local single = false
  local double = false
  local escaped = false
  for c in string.gmatch(str, '.') do
    if single then
      if c == "'" then
        single = false
      else
        accumulator = accumulator .. c
      end
      goto continue
    end

    if double then
      if escaped then
        if c == '"' then
          accumulator = accumulator .. c
        else
          accumulator = accumulator .. '\\' .. c
        end
        escaped = false
        goto continue
      end

      if c == '\\' then
        escaped = true
        goto continue
      end

      if c == '"' then
        double = false
      else
        accumulator = accumulator .. c
      end

      goto continue
    end

    if escaped then
      if c ~= ' ' and c ~= '"' and c ~= "'" then
        accumulator = accumulator .. '\\'
      end
      accumulator = accumulator .. c
      escaped = false
      goto continue
    end

    if c == '\\' then
      escaped = true
      goto continue
    end

    if c == "'" then
      single = true
      goto continue
    end

    if c == '"' then
      double = true
      goto continue
    end

    if (c == ' ' or c == '\n') then
      if #accumulator > 0 then
        table.insert(output, accumulator)
        accumulator = ''
      end
      goto continue
    end

    accumulator = accumulator .. c
    ::continue::
  end

  if #accumulator > 0 then
    table.insert(output, accumulator)
  end
  return output
end

local function close_all(pattern)
  if not pattern or type(pattern) ~= 'string' then
    vim.notify('Expected a pattern to match buffer names', vim.log.levels.ERROR)
    return
  end

  local buf_nrs = vim.api.nvim_list_bufs()
  local buffer_stack = require('plugin.buffer_stack')
  for _, b in ipairs(buf_nrs) do
    if vim.api.nvim_buf_is_loaded(b) then
      local name = string.gsub(vim.fn.expand('#' .. b), vim.env.HOME, '~', 1)
      if string.find(name, pattern) then
        vim.notify('Deleting ' .. name)
        buffer_stack.delete(b)
      end
    end
  end
end

return {
  extract_color = extract_color,
  float = float,
  map = map,
  map_check = map_check,
  mod = mod,
  parse_args = parse_args,
  close_all = close_all,
}
