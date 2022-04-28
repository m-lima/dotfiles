local float_raw = function(str, ft)
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

local float = function(cmd)
  local str = vim.inspect(cmd)

  float_raw(str, 'lua')
end

vim.api.nvim_create_user_command(
  'LuaOut',
  'lua require("script.output").float(<args>)',
  {
    desc = 'Display lua output as a floating window',
    nargs = 1,
  }
)

return {
  float = float,
  float_raw = float_raw
}
