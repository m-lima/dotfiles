local clients = {}

local make_deferred = function(opts, one_shot)
  if not opts.handlers then
    opts.handlers = {}
  end

  local on_attach = opts.on_attach
  local deferred_attach = function(bufnr)
    vim.api.nvim_buf_call(bufnr, on_attach)
  end

  opts.handlers = {
    ['experimental/serverStatus'] = function(err, res, ctx)
      if not err and res.quiescent then
        local client_instance = clients[ctx.client_id]
        if one_shot then
          one_shot()
        end
        if client_instance then
          client_instance.done = true
          if client_instance.queue then
            for _, bufnr in ipairs(client_instance.queue) do
              deferred_attach(bufnr)
            end
            client_instance = nil
          end
        else
          clients[ctx.client_id] = {
            done = true
          }
        end
      end
    end
  }

  opts.on_attach = function(client, bufnr)
    local client_instance = clients[client.id]
    if client_instance then
      if client_instance.done then
        deferred_attach(bufnr)
      else
        table.insert(client_instance.queue, bufnr)
      end
    else
      clients[client.id] = {
        queue = { bufnr }
      }
    end
  end

  opts.capabilities = vim.tbl_deep_extend('force', { experimental = { serverStatusNotification = true }}, opts.capabilities or {})

  return opts
end

return {
  make_deferred = make_deferred,
}
