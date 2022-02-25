local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require({
  highlight = 'lualine.highlight',
})
local filename = require('lualine.components.filename'):extend()

local function paste()
  if vim.o.paste then
    return ''
  else
    return ''
  end
end

local function color_from_hl(name, default)
  if vim.fn.hlexists(name) == 0 then
    return default
  end
  local color = vim.api.nvim_get_hl_by_name(name, true)
  if color.foreground ~= nil then
    return string.format('#%06x', color.foreground)
  end
  return default
end

local changed_buffers = require('lualine.component'):extend()

function changed_buffers:init(options)
  changed_buffers.super.init(self, options)

  local color = self.options.color and self.options.color or 'DiffAdd'

  if type(color) == 'string' then
    if string.sub(color, 1, 1) ~= '#' then
      color = color_from_hl(color, '#87ff5f')
    end
  elseif type(color) ~= 'number' then
    return error('Unrecognized color type')
  end

  self.color = modules.highlight.create_component_highlight_group({ fg = color }, 'changed_buffers', self.options)
end

function changed_buffers:update_status()
  local current = vim.api.nvim_get_current_buf()
  local buf_count =  #vim.tbl_filter(function(b)
      return b.changed == 1 and b.bufnr ~= current
    end, vim.fn.getbufinfo({ bufmodified = 1 }))

  if buf_count > 0 then
    return modules.highlight.component_format_highlight(self.color) .. buf_count
  else
    return ''
  end
end

function filename:init(options)
  filename.super.init(self, options)

  local color = self.options.color and self.options.color or 'DiffChange'

  if type(color) == 'string' then
    if string.sub(color, 1, 1) ~= '#' then
      color = color_from_hl(color, '#51a0cf')
    end
  elseif type(color) ~= 'number' then
    return error('Unrecognized color type')
  end

  self.color = modules.highlight.create_component_highlight_group({ fg = color }, 'filename_status_modified', self.options)
end

function filename:update_status()
  local data = filename.super.update_status(self)
  if vim.bo.modified then
    data = modules.highlight.component_format_highlight(self.color) .. data
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
