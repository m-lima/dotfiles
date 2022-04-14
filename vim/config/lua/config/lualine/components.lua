local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require({
  highlight = 'lualine.highlight',
})
local Job = require('plenary.job')
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

  self.color = modules.highlight.create_component_highlight_group({ fg = fg, bg = bg }, 'changed_buffers', self.options)
end

function changed_buffers:update_status()
  local buf_count = #vim.tbl_filter(function(b)
    return b.changed == 1
  end, vim.fn.getbufinfo({ bufmodified = 1 }))

  if buf_count > 0 then
    return modules.highlight.component_format_highlight(self.color) .. buf_count
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

  self.color = modules.highlight.create_component_highlight_group({ fg = color }, 'filename_status_modified', self.options)
end

function filename:update_status()
  local data = filename.super.update_status(self)
  if vim.bo.modified then
    data = modules.highlight.component_format_highlight(self.color) .. data
  end

  return data
end

local git_status = require('lualine.components.filename'):extend()
local git_status_active_buffer = '0'
local git_status_args = nil
local git_status_output = ''
local git_status_parse = function(output)
  if output and #output > 2 then
    output = output:sub(1, 2)
    if output == '!!' then
      git_status_output = '◌'
    elseif output == '??' then
      git_status_output = ''
    else
      output = output:gsub('^U', '')
      output = output:gsub('U$', '')

      output = output:gsub(' ', '')
      output = output:gsub('A', '')
      output = output:gsub('D', '')
      output = output:gsub('R', '')
      output = output:gsub('M', '')
      git_status_output = output
    end
  else
    git_status_output = ''
  end
end

function git_status:init(options)
  git_status.super.init(self, options)

  vim.cmd([[
    augroup pluginLualineGitstatus
      autocmd! *
      autocmd BufEnter * silent! lua require('config.lualine.components').git_status.deep_refresh()
      autocmd BufWritePre * silent! lua require('config.lualine.components').git_status.refresh()
    augroup END
  ]])
  git_status.deep_refresh()
end

function git_status:update_status()
  if vim.g.actual_curbuf ~= nil and git_status_active_buffer ~= vim.g.actual_curbuf then
    git_status.deep_refresh()
  end
  return git_status_output
end

function git_status:deep_refresh()
  git_status_output = ''
  git_status_active_buffer = tostring(vim.api.nvim_get_current_buf())
  if vim.bo.readonly or #vim.fn.expand('%') == 0 then
    git_status_args = nil
    git_status_output = ''
  else
    git_status_args = { '-C', vim.fn.expand('%:h'), 'status', '--porcelain', '--ignored', '--', vim.fn.expand('%:t') }
    git_status.refresh()
  end
end

function git_status:refresh()
  if git_status_args then
    Job:new({
      command = 'git',
      args = git_status_args,
      on_exit = function(job, status)
        if status == 0 then
          git_status_parse(job:result()[1])
        else
          git_status_output = ''
        end
      end,
    }):start()
  end
end

return {
  paste = paste,
  changed_buffers = changed_buffers,
  filename = filename,
  location = '%l/%L:%-1v',
  toggleterm = 'b:toggle_number',
  git_status = git_status,
}
