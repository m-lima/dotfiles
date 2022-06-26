local lualine = require('lualine')
local highlight = require('lualine.highlight')
local defer_lsp = require('plugin.defer_lsp')

local lsp_status = require('lualine.component'):extend()

function lsp_status:init(options)
  self.super.init(self, options)
  self.spinner = { '⡆', '⠇', '⠋', '⠙', '⠸', '⢰', '⣠', '⣄' }
  self.spinner_index = 1
  self.spinner_color = highlight.create_component_highlight_group({ fg = '#ff7f50' }, 'lsp_status', self.options)
end

function lsp_status:update_status()
  local requests = defer_lsp.running_requests()
  if #requests == 0 then
    if self.timer then
      self.timer:stop()
      self.timer = nil
    end
    return
  end

  print(vim.inspect(requests))
  if not self.timer then
    self.timer = vim.loop.new_timer()
    self.timer:start(0, 200, function()
      if self.spinner_index == #self.spinner then
        self.spinner_index = 1
      else
        self.spinner_index = self.spinner_index + 1
      end
      vim.schedule(lualine.statusline)
    end)
  end

  requests = table.concat(requests, ' ')
  local spinner = highlight.component_format_highlight(self.spinner_color) ..
      self.spinner[self.spinner_index] ..
      self.super.get_default_hl(self)
  return spinner .. ' ' .. requests
end

return lsp_status
