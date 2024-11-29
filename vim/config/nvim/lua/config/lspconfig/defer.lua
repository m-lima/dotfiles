local trackers = {}

local defer = function(server, opts, one_shot)
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
          if type(one_shot) == 'function' then
            one_shot()
          else
            vim.notify('Field `one_shot` is not a function for ' .. server, vim.log.levels.WARN)
          end
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

  opts.capabilities = vim.tbl_deep_extend('force', { experimental = { serverStatusNotification = true } },
    opts.capabilities or {})

  return opts
end

return defer
