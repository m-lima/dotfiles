local highlight = require('lualine.highlight')
local extract_color = require('util').extract_color

local function paste()
  if vim.o.paste then
    return ''
  else
    return ''
  end
end

local changed_buffers = require('lualine.component'):extend()

function changed_buffers:init(options)
  changed_buffers.super.init(self, options)

  local fg = self.options.color and self.options.color.fg and self.options.color.fg or '#3a3a3a'
  local bg = self.options.color and self.options.color.bg and self.options.color.bg or 'DiffChange'

  if type(fg) == 'string' then
    if string.sub(fg, 1, 1) ~= '#' then
      fg = extract_color(fg, '#3a3a3a')
    end
  elseif type(fg) ~= 'number' then
    return error('Unrecognized foreground color type')
  end

  if type(bg) == 'string' then
    if string.sub(bg, 1, 1) ~= '#' then
      bg = extract_color(bg, '#51a0cf')
    end
  elseif type(bg) ~= 'number' then
    return error('Unrecognized background color type')
  end

  self.color = highlight.create_component_highlight_group({ fg = fg, bg = bg }, 'changed_buffers', self.options)
end

function changed_buffers:update_status()
  local buf_count = #vim.tbl_filter(function(b)
    return b.changed == 1
  end, vim.fn.getbufinfo({ bufmodified = 1 }))

  if buf_count > 0 then
    return highlight.component_format_highlight(self.color) .. buf_count
  else
    return ''
  end
end

local filename = require('lualine.components.filename'):extend()

function filename:init(options)
  filename.super.init(self, options)

  local normal = self.options.normal and self.options.normal or '#cccccc'
  local changed = self.options.changed and self.options.changed or 'DiffChange'

  if type(normal) == 'string' then
    if string.sub(normal, 1, 1) ~= '#' then
      normal = extract_color(normal, '#cccccc')
    end
  elseif type(normal) ~= 'number' then
    return error('Unrecognized color type')
  end

  if type(changed) == 'string' then
    if string.sub(changed, 1, 1) ~= '#' then
      changed = extract_color(changed, '#51a0cf')
    end
  elseif type(changed) ~= 'number' then
    return error('Unrecognized color type')
  end

  self.normal = highlight.create_component_highlight_group({ fg = normal }, 'filename_status_normal', self.options)
  self.changed = highlight.create_component_highlight_group({ fg = changed }, 'filename_status_changed', self.options)
end

function filename:update_status()
  local data = string.gsub(vim.fn.getcwd(), vim.env.HOME, '~', 1) .. '  '

  if vim.bo.modified then
    data = data .. highlight.component_format_highlight(self.changed)
  else
    data = data .. highlight.component_format_highlight(self.normal)
  end

  return data .. filename.super.update_status(self)
end

local active_lsp = require('lualine.component'):extend()

function active_lsp:init(options)
  active_lsp.super.init(self, options)

  self.color = highlight.create_component_highlight_group({ fg = '#ffffff' }, 'active_lsp', self.options)
end

local group_clients = function()
  local clients = {}
  local curr_bufnr = vim.api.nvim_get_current_buf()

  for _, client in ipairs(vim.lsp.get_clients()) do
    local client_object = {
      id = client.id,
      current = false,
    }

    if client.attached_buffers[curr_bufnr] then
      client_object.current = true
    end

    if clients[client.name] then
      table.insert(clients[client.name], client_object)
    else
      clients[client.name] = { client_object }
    end
  end

  local multiple = 0
  for _, _ in pairs(clients) do
    multiple = multiple + 1
  end

  return clients, multiple > 1
end

function active_lsp:update_status()
  local clients, multiple = group_clients()
  local output = ''
  local empty = true

  for k, v in pairs(clients) do
    local current = false

    if not empty then
      output = output .. ' '
    else
      empty = false
    end

    for i, c in ipairs(v) do
      if i > 1 then
        output = output .. ':'
      end

      if c.current then
        output = output ..
            highlight.component_format_highlight(self.color) .. c.id .. active_lsp.super.get_default_hl(self)
        current = true
      else
        output = output .. c.id
      end
    end

    if not current or multiple then
      output = output .. ':' .. k
    end
  end

  return output
end

return {
  paste = paste,
  changed_buffers = changed_buffers,
  filename = filename,
  active_lsp = active_lsp,
  location = '%l/%L:%-1v',
  toggleterm = 'b:toggle_number',
}
