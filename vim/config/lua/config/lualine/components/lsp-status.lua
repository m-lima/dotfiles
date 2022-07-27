local lualine = require('lualine')
local highlight = require('lualine.highlight')

local lsp_status = require('lualine.component'):extend()

local method_to_capability = {
  ['textDocument/declaration'] = 'declarationProvider',
  ['textDocument/definition'] = 'definitionProvider',
  ['textDocument/typeDefinition'] = 'typeDefinitionProvider',
  ['textDocument/implementation'] = 'implementationProvider',
  ['textDocument/references'] = 'referencesProvider',
  ['textDocument/prepareCallHierarchy'] = 'callHierarchyProvider',
  ['callHierarchy/incomingCalls'] = 'callHierarchyProvider',
  ['callHierarchy/outgoingCalls'] = 'callHierarchyProvider',
  ['textDocument/prepareTypeHierarchy'] = 'typeHierarchyProvider',
  ['typeHierarchy/supertypes'] = 'typeHierarchyProvider',
  ['typeHierarchy/subtypes'] = 'typeHierarchyProvider',
  ['textDocument/documentHighlight'] = 'documentHighlightProvider',
  ['textDocument/documentLink'] = 'documentLinkProvider',
  ['documentLink/resolve'] = 'documentLinkProvider',
  ['textDocument/hover'] = 'hoverProvider',
  ['textDocument/codeLens'] = 'codeLensProvider',
  ['codeLens/resolve'] = 'codeLensProvider',
  ['textDocument/foldingRange'] = 'foldingRangeProvider',
  ['textDocument/selectionRange'] = 'selectionRangeProvider',
  ['textDocument/documentSymbol'] = 'documentSymbolProvider',
  ['textDocument/semanticTokens/full'] = 'semanticTokensProvider',
  ['textDocument/semanticTokens/full/delta'] = 'semanticTokensProvider',
  ['textDocument/semanticTokens/range'] = 'semanticTokensProvider',
  ['textDocument/inlayHint'] = 'inlayHintProvider',
  ['inlayHint/resolve'] = 'inlayHintProvider',
  ['textDocument/inlineValue'] = 'inlineValueProvider',
  ['textDocument/moniker'] = 'monikerProvider',
  ['textDocument/completion'] = 'completionProvider',
  ['completionItem/resolve'] = 'completionProvider',
  ['textDocument/diagnostic'] = 'diagnosticProvider',
  ['workspace/diagnostic'] = 'diagnosticProvider',
  ['textDocument/signatureHelp'] = 'signatureHelpProvider',
  ['textDocument/codeAction'] = 'codeActionProvider',
  ['codeAction/resolve'] = 'codeActionProvider',
  ['textDocument/documentColor'] = 'colorProvider',
  ['textDocument/colorPresentation'] = 'colorProvider',
  ['textDocument/formatting'] = 'documentFormattingProvider',
  ['textDocument/rangeFormatting,'] = 'documentRangeFormattingProvider',
  ['textDocument/onTypeFormatting'] = 'documentOnTypeFormattingProvider',
  ['textDocument/rename'] = 'renameProvider',
  ['textDocument/prepareRename'] = 'renameProvider',
  ['textDocument/linkedEditingRange'] = 'linkedEditingRangeProvider',
  ['workspace/symbol'] = 'workspaceSymbolProvider',
  ['workspaceSymbol/resolve'] = 'workspaceSymbolProvider',
}

local workspace_method_to_capability = {
  ['workspace/willCreateFiles'] = function(cap) return cap.fileOperations and cap.fileOperations.willCreate end,
  ['workspace/willRenameFiles'] = function(cap) return cap.fileOperations and cap.fileOperations.willRename end,
  ['workspace/willDeleteFiles'] = function(cap) return cap.fileOperations and cap.fileOperations.willDelete end,
  ['workspace/executeCommand'] = function(cap) return cap.executeCommand end,
}

function lsp_status:init(options)
  self.super.init(self, options)

  self.spinner = { '⡆', '⠇', '⠋', '⠙', '⠸', '⢰', '⣠', '⣄' }
  self.spinner_index = 1
  self.spinner_color = highlight.create_component_highlight_group({ fg = '#ff7f50' }, 'lsp_status', self.options)

  self.title_color = highlight.create_component_highlight_group({ fg = '#c0c0c0' }, 'lsp_status', self.options)
  self.message_color = highlight.create_component_highlight_group({ fg = '#a0a0a0' }, 'lsp_status', self.options)
  self.percentage_color = highlight.create_component_highlight_group({ fg = '#808080' }, 'lsp_status', self.options)

  self.clients = {}

  self:register_progress()
  self:register_request()
end

function lsp_status:get_client(client_id)
  if not self.clients[client_id] then
    self.clients[client_id] = {
      name = vim.lsp.get_client_by_id(client_id).name,
      progresses = {},
      requests = {},
    }
  end
  return self.clients[client_id]
end

function lsp_status:clean_client(client_id)
  if self.clients[client_id] and vim.tbl_isempty(self.clients[client_id].progresses) and
      vim.tbl_isempty(self.clients[client_id].requests) then
    self.clients[client_id] = nil
  end
end

function lsp_status:register_progress()
  local progress_callback = function(msg, client_id)
    local key = msg.token
    if not key then return end

    local value = msg.value
    if not value then return end

    local client = self:get_client(client_id)

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
      self:clean_client(client_id)
    end
  end

  vim.lsp.handlers['$/progress'] = function(_err, result, ctx, _config)
    if result and ctx and ctx.client_id then
      progress_callback(result, ctx.client_id)
    end
  end
end

function lsp_status:register_request()
  if vim.lsp.already_registered then return end
  vim.lsp.already_registered = true

  local req = vim.lsp.buf_request
  local req_all = vim.lsp.buf_request_all
  local req_sync = vim.lsp.buf_request_sync

  vim.lsp.buf_request = function(bufnr, method, params, orig_handler)
    if not method or #method == 0 then
      return req(bufnr, method, params, orig_handler)
    end
    local clients = vim.lsp.buf_get_clients(bufnr)
    if not clients or #clients == 0 then
      return req(bufnr, method, params, orig_handler)
    end

    local id = math.random()
    local class, name = unpack(vim.split(method, '/'))

    for client_id, client in pairs(clients) do
      if method_to_capability[method] then
        if client.server_capabilities[ method_to_capability[method] ] then
          self:get_client(client_id).requests[id] = name
        end
      elseif class == 'experimental' then
        if client.server_capabilities.experimental and client.server_capabilities.experimental[name] then
          self:get_client(client_id).requests[id] = name
        end
      elseif class == 'workspace' and workspace_method_to_capability[method] and client.server_capabilities.workspace then
        if workspace_method_to_capability[method](client.server_capabilities.workspace) then
          self:get_client(client_id).requests[id] = name
        end
      end
    end

    local handler = function(err, result, ctx, config)
      self.clients[ctx.client_id].requests[id] = nil
      self:clean_client(ctx.client_id)

      if orig_handler then
        orig_handler(err, result, ctx, config)
      else
        vim.lsp.handlers[method](err, result, ctx, config)
      end
    end
    return req(bufnr, method, params, handler)
  end

  vim.lsp.buf_request_all = function(bufnr, method, params, orig_callback)
    if not method or #method == 0 then
      return req_all(bufnr, method, params, orig_callback)
    end
    local clients = vim.lsp.buf_get_clients(bufnr)
    if not clients or #clients == 0 then
      return req_all(bufnr, method, params, orig_callback)
    end

    local id = math.random()
    local name = method:match('/(.*)')

    for client_id, _ in pairs(clients) do
      self:get_client(client_id).requests[id] = name
    end

    local callback = function(err, result, ctx, config)
      for client_id, _ in pairs(clients) do
        self.clients[client_id].requests[id] = nil
        self:clean_client(client_id)
      end

      orig_callback(err, result, ctx, config)
    end
    return req_all(bufnr, method, params, callback)
  end

  vim.lsp.buf_request_sync = function(bufnr, method, params, timeout_ms)
    if not method or #method == 0 then
      return req_sync(bufnr, method, params, timeout_ms)
    end
    local clients = vim.lsp.buf_get_clients(bufnr)
    if not clients or #clients == 0 then
      return req_sync(bufnr, method, params, timeout_ms)
    end

    local id = math.random()
    local name = method:match('/(.*)')

    for client_id, _ in pairs(clients) do
      self:get_client(client_id).requests[id] = name
    end

    local result, err = req_sync(bufnr, method, params, timeout_ms)

    for client_id, _ in pairs(clients) do
      self.clients[client_id].requests[id] = nil
      self:clean_client(client_id)
    end

    return result, err
  end
end

function lsp_status:update_status()
  if vim.tbl_isempty(self.clients) then
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
    local client_tasks = {}
    for _, task in pairs(client.progresses) do
      if task.title then
        table.insert(client_tasks, highlight.component_format_highlight(self.title_color) .. task.title)
        if task.message then
          table.insert(client_tasks, highlight.component_format_highlight(self.message_color) .. task.message)
        end
        if task.percentage then
          table.insert(client_tasks,
            highlight.component_format_highlight(self.percentage_color) .. task.percentage .. '%%')
        end
      end
    end

    if not vim.tbl_isempty(client.requests) then
      table.insert(client_tasks,
        highlight.component_format_highlight(self.title_color) .. table.concat(vim.tbl_values(client.requests), ' '))
    end

    if #client_tasks > 0 then
      client_tasks = table.concat(client_tasks, ' ') .. self.super.get_default_hl(self)
      table.insert(progress, client_tasks)
    end
  end

  progress = table.concat(progress, ' ╱ ')
  return spinner .. ' ' .. progress
end

return lsp_status
