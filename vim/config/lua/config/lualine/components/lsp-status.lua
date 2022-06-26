local lualine = require('lualine')
local highlight = require('lualine.highlight')
local defer_lsp = require('plugin.defer_lsp')

local lsp_status = require('lualine.component'):extend()

function lsp_status:init(options)
  self.super.init(self, options)

  self.spinner = { '⡆', '⠇', '⠋', '⠙', '⠸', '⢰', '⣠', '⣄' }
  self.spinner_index = 1
  self.spinner_color = highlight.create_component_highlight_group({ fg = '#ff7f50' }, 'lsp_status', self.options)

  self.title_color = highlight.create_component_highlight_group({ fg = '#c0c0c0' }, 'lsp_status', self.options)
  self.message_color = highlight.create_component_highlight_group({ fg = '#a0a0a0' }, 'lsp_status', self.options)
  self.percentage_color = highlight.create_component_highlight_group({ fg = '#808080' }, 'lsp_status', self.options)
  self.clients = {}
  self:register()
end

function lsp_status:register()
  local progress_callback = function(msg, client_id)
    local key = msg.token
    if not key then return end

    local value = msg.value
    if not value then return end

    if not self.clients[client_id] then
      self.clients[client_id] = {
        progresses = {},
        name = vim.lsp.get_client_by_id(client_id).name,
      }
    end
    local client = self.clients[client_id]

    if not client.progresses[key] then
      client.progresses[key] = {}
    end
    local progress = client.progresses[key]

    if value.kind == 'begin' then
      progress.title = value.title
    elseif value.kind == 'report' then
      if value.percentage then
        progress.percentage = value.percentage
      end
      if value.message then
        progress.message = value.message
      end
    elseif value.kind == 'end' then
      client.progresses[key] = nil

      if #client.progresses == 0 then
        self.clients[client_id] = nil
      end
    end
  end

  vim.lsp.handlers['$/progress'] = function(_err, result, ctx, _config)
    if result and ctx and ctx.client_id then
      progress_callback(result, ctx.client_id)
    end
  end
end

function lsp_status:update_status()
  local requests = defer_lsp.running_requests()
  if #requests == 0 and #self.clients == 0 then
    if self.timer then
      self.timer:stop()
      self.timer = nil
    end
    return
  end

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

  local spinner = highlight.component_format_highlight(self.spinner_color) ..
      self.spinner[self.spinner_index]

  local progress = {}
  for _, client in pairs(self.clients) do
    local client_progress = {}
    for _, task in pairs(client.progresses) do
      if task.title then
        table.insert(client_progress, highlight.component_format_highlight(self.title_color) .. task.title)
        if task.message then
          table.insert(client_progress, highlight.component_format_highlight(self.message_color) .. task.message)
        end
        if task.percentage then
          table.insert(client_progress, highlight.component_format_highlight(self.percentage_color) .. task.percentage)
        end
      end
    end

    if #client_progress > 0 then
      client_progress = table.concat(client_progress, ' ') .. self.super.get_default_hl(self)
      table.insert(progress, client_progress)
    end
  end

  if #requests > 0 then
    table.insert(progress, highlight.component_format_highlight(self.message_color) .. table.concat(requests, ' '))
  end

  progress = table.concat(progress, ' ╱ ')
  return spinner .. ' ' .. progress
end

return lsp_status
