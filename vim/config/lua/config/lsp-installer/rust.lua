vim.lsp.commands['rust-analyzer.runSingle'] = function(cmd)
  if cmd then
    local arguments = cmd.arguments[1]
    cmd = 'cargo'
    for _, v in ipairs(arguments.args.cargoArgs or {}) do
      cmd = cmd .. ' ' .. v
    end
    for _, v in ipairs(arguments.args.cargoExtraArgs or {}) do
      cmd = cmd .. ' ' .. v
    end
    cmd = cmd .. ' --'
    for _, v in ipairs(arguments.args.executableArgs or {}) do
      cmd = cmd .. ' ' .. v
    end

    if arguments.args.cargoArgs[1] == 'run' then
      local args = vim.fn.input('Args: ')
      if args and #args > 0 then
        cmd = cmd .. ' ' .. args
      end
    end

    local cwd = arguments.workspaceRoot
    require('config.toggleterm.extension').runner(cmd, cwd)
  end
end

vim.lsp.commands['rust-analyzer.debugSingle'] = function(cmd)
  local arguments = cmd.arguments[1]

  local cargo_args = arguments.args.cargoArgs
  table.insert(cargo_args, '--message-format=json')
  cargo_args = vim.list_extend(cargo_args, arguments.args.cargoExtraArgs)

  require('plenary.job'):new({
    command = 'cargo',
    args = cargo_args,
    cwd = arguments.workspaceRoot,
    on_exit = function(job, code)
      if code and code > 0 then
        vim.schedule(function()
          vim.notify('An error occured while compiling. Please fix all compilation issues and try again.',
            vim.log.levels.ERROR)
        end)
      end

      vim.schedule(function()
        for _, value in pairs(job:result()) do
          local json = vim.fn.json_decode(value)
          if type(json) == 'table' and json.executable ~= vim.NIL and json.executable ~= nil then
            require('dap').run({
              name = 'Rust debug',
              type = 'codelldb',
              request = 'launch',
              program = json.executable,
              args = arguments.executableArgs or {},
              cwd = arguments.workspaceRoot,
              stopOnEntry = false,
              runInTerminal = false,
            })
            break
          end
        end
      end)
    end,
  }):start()
end

local prepare = function(opts)
  opts.settings = {
    ['rust-analyzer'] = {
      inlayHints = {
        chainingHints = true,
        parameterHints = false,
        reborrowHints = true,
        typeHints = true,
        closureReturnTypeHints = true,
        maxLength = 100,
        renderColons = true,
      },
      checkOnSave = {
        command = 'clippy',
        extraArgs = { '--', '-W', 'clippy::pedantic' },
      },
    },
  }

  local on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'RustReload',
      function()
        vim.lsp.buf_request(
          0,
          'rust-analyzer/reloadWorkspace',
          nil,
          function(err, res, ctx)
            if err then
              vim.notify(err, vim.log.level.ERROR)
            end
          end
        )
      end,
      { desc = 'Reload Rust' }
    )
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'RustExpand',
      function()
        vim.lsp.buf_request(
          0,
          'rust-analyzer/expandMacro',
          vim.lsp.util.make_position_params(),
          function(err, res, ctx)
            if err then
              vim.notify(err, vim.log.level.ERROR)
            else
              require('util').float.show_raw(res.expansion, 'rust')
            end
          end
        )
      end,
      { desc = 'Expand Rust macro' }
    )
  end

  return require('plugin.defer_lsp').defer(opts)
end

return {
  prepare = prepare,
}
