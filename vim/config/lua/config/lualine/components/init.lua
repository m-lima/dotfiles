local highlight = require('lualine.highlight')
local extract_color = require('script.helper').extract_color

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

  local color = self.options.color and self.options.color or 'DiffChange'

  if type(color) == 'string' then
    if string.sub(color, 1, 1) ~= '#' then
      color = extract_color(color, '#51a0cf')
    end
  elseif type(color) ~= 'number' then
    return error('Unrecognized color type')
  end

  self.color = highlight.create_component_highlight_group({ fg = color }, 'filename_status_modified', self.options)
end

function filename:update_status()
  local data = filename.super.update_status(self)
  if vim.bo.modified then
    data = highlight.component_format_highlight(self.color) .. data
  end

  return data
end

return {
  paste = paste,
  changed_buffers = changed_buffers,
  filename = filename,
  location = '%l/%L:%-1v',
  toggleterm = 'b:toggle_number',
}
