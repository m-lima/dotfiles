local register = require('config.lspconfig.register')

local setup = function()
  register('lua_ls', {
    features = {
      name = 'lua',
    },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        telemetry = {
          enable = false,
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  })

  register('eslint', {
    features = { format = 'EslintFixAll' }
  })

  register('volar', {
    features = { format = false }
  })

  register('pyright')
  register('hls')
  register('gopls')
  register('tsserver')

  register('rust_analyzer',
    {
      one_shot = function()
        local extract_build_args = function(args)
          if args[1] == 'run' then
            local build_args = { 'build', '--message-format=json' }
            vim.list_extend(build_args, args, 2)
            return false, build_args
          elseif args[1] == 'test' then
            local build_args = { 'build', '--message-format=json', '--tests' }
            local skip = true
            for _, v in ipairs(args) do
              if skip then
                skip = false
              else
                if v == '--bin' then
                  skip = true
                else
                  table.insert(build_args, v)
                end
              end
            end
            return true, build_args
          end
          vim.notify('Unrecognized cargo command arguments: ' .. vim.inspect(args))
        end

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
            else
              cmd = cmd .. ' --color=always'
            end

            local cwd = arguments.workspaceRoot
            require('config.toggleterm.extension').runner(cmd, cwd)
          end
        end

        vim.lsp.commands['rust-analyzer.debugSingle'] = function(cmd)
          local arguments = cmd.arguments[1]

          local cargo_args = arguments.args.cargoArgs
          cargo_args = vim.list_extend(cargo_args, arguments.args.cargoExtraArgs)
          local is_test, build_args = extract_build_args(cargo_args)

          if not build_args then
            return
          end

          -- Extract executable hint, if this is a test
          local name = nil
          if is_test then
            local next = false
            for _, value in ipairs(build_args) do
              if next then
                name = 'deps/' .. value
                break
              end
              if value == '--test' or value == '--bin' then
                next = true
              end
            end
          end

          print('Building workspace..')
          require('plenary.job'):new({
            command = 'cargo',
            args = build_args,
            cwd = arguments.args.workspaceRoot,
            on_stdout = function(error)
              vim.schedule(function()
                if error then
                  vim.notify(error, vim.log.levels.ERROR)
                end
              end)
            end,
            on_stderr = function(error, data)
              vim.schedule(function()
                if error then
                  vim.notify(error, vim.log.levels.ERROR)
                end
                if data then
                  vim.notify(data)
                end
              end)
            end,
            on_exit = function(job, code)
              if code and code > 0 then
                vim.schedule(function()
                  vim.notify(
                    'An error occured while compiling. Please fix all compilation issues and try again.',
                    vim.log.levels.ERROR
                  )
                end)
                return
              end

              vim.schedule(function()
                for _, value in pairs(job:result()) do
                  local json = vim.fn.json_decode(value)
                  if type(json) == 'table'
                      and json.executable ~= vim.NIL
                      and json.executable ~= nil
                      and (not name or string.find(json.executable, name))
                  then

                    local run_args
                    if is_test then
                      run_args = arguments.args.executableArgs
                    else
                      run_args = require('util').parse_args(vim.fn.input('Args: '))
                    end

                    vim.notify('Running: ' .. json.executable .. ' :: ' .. vim.inspect(run_args))

                    require('dap').run({
                      name = 'Rust debug',
                      type = 'codelldb',
                      request = 'launch',
                      program = json.executable,
                      args = run_args or {},
                      cwd = arguments.args.workspaceRoot,
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
      end,
      features = {
        name = 'rust',
        extra = function(_, bufnr)
          vim.api.nvim_buf_create_user_command(
            bufnr,
            'RustReload',
            function()
              vim.lsp.buf_request(
                bufnr,
                'rust-analyzer/reloadWorkspace',
                nil,
                function(err, _, _)
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
            'ExpandMacro',
            function()
              vim.lsp.buf_request(
                bufnr,
                'rust-analyzer/expandMacro',
                vim.lsp.util.make_position_params(),
                function(err, res, _)
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
        end,
      },
      settings = {
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
      },
    },
    true)
end

return {
  setup = setup,
}
