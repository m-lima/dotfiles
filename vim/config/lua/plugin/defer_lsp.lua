local trackers = {}

local defer = function(opts, one_shot)
  if not opts.handlers then
    opts.handlers = {}
  end

  local on_attach = opts.on_attach
  local deferred_attach = function(client, bufnr)
    vim.api.nvim_buf_call(bufnr, function() on_attach(client, bufnr) end)
  end

  opts.handlers = {
    ['experimental/serverStatus'] = function(err, res, ctx)
      if not err and res.quiescent then
        local tracked_instance = trackers[ctx.client_id]
        if one_shot then
          one_shot()
        end
        if tracked_instance then
          tracked_instance.done = true
          if tracked_instance.queue then
            local tracked_client = vim.lsp.get_client_by_id(ctx.client_id)
            for _, bufnr in ipairs(tracked_instance.queue) do
              deferred_attach(tracked_client, bufnr)
            end
          end
        else
          trackers[ctx.client_id] = {
            done = true
          }
        end
      end
    end
  }

  opts.on_attach = function(client, bufnr)
    local tracked_instance = trackers[client.id]
    if tracked_instance then
      if tracked_instance.done then
        deferred_attach(client, bufnr)
      else
        table.insert(tracked_instance.queue, bufnr)
      end
    else
      trackers[client.id] = {
        queue = { bufnr }
      }
    end
  end

  opts.capabilities = vim.tbl_deep_extend('force', { experimental = { serverStatusNotification = true }}, opts.capabilities or {})

  return opts
end

local running_tasks_map = {}
local uninitialized = true

local setup = function()
  if uninitialized then
    local req = vim.lsp.buf_request
    local req_all = vim.lsp.buf_request_all
    local req_sync = vim.lsp.buf_request_sync

    vim.lsp.buf_request = function(bufnr, method, params, orig_handler)
      local id = math.random()
      running_tasks_map[id] = method:match('/(.*)')
      local handler = function(err, result, ctx, config)
        running_tasks_map[id] = nil
        if orig_handler then
          orig_handler(err, result, ctx, config)
        end
      end
      return req(bufnr, method, params, handler)
    end

    vim.lsp.buf_request_all = function(bufnr, method, params, orig_callback)
      local id = math.random()
      running_tasks_map[id] = method:match('/(.*)')
      local callback = function(err, result, ctx, config)
        running_tasks_map[id] = nil
        if orig_callback then
          orig_callback(err, result, ctx, config)
        end
      end
      return req_all(bufnr, method, params, callback)
    end

    vim.lsp.buf_request_sync = function(bufnr, method, params, timeout_ms)
      local id = math.random()
      running_tasks_map[id] = method:match('/(.*)')
      local result, err = { req_sync(bufnr, method, params, timeout_ms) }
      running_tasks_map[id] = nil
      return result, err
    end

    uninitialized = false
  end
end

local running_tasks = function()
  return vim.tbl_values(running_tasks_map)
end

return {
  defer = defer,
  setup = setup,
  running_tasks = running_tasks,
}
