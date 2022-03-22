local utils = require('lspconfig.util')

vim.lsp.commands['rust-analyzer.runSingle'] = function(cmd)
  if cmd then
    local arguments = cmd.arguments[1]
    local cmd = 'cargo'
    for _,v in ipairs(arguments.args.cargoArgs or {}) do
      cmd = cmd .. ' ' .. v
    end
    for _,v in ipairs(arguments.args.cargoExtraArgs or {}) do
      cmd = cmd .. ' ' .. v
    end
    cmd = cmd .. ' --'
    for _,v in ipairs(arguments.args.executableArgs or {}) do
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

local root_dir = function(filename)
  filename = filename or vim.api.nvim_buf_get_name(0)

  local manifest_dir = utils.root_pattern('Cargo.toml')(filename)
  local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
  if manifest_dir ~= nil then
    cmd[#cmd + 1] = '--manifest-path'
    cmd[#cmd + 1] = utils.path.join(manifest_dir, 'Cargo.toml')
  end

  local cargo_metadata = ''
  local cargo_metadata_job = vim.fn.jobstart(cmd, {
    on_stdout = function(_, out, _)
      cargo_metadata = table.concat(out, '\n')
    end,
    stdout_buffered = true,
  })

  if cargo_metadata_job > 0 then
    cargo_metadata_job = vim.fn.jobwait({ cargo_metadata_job })[1]
  else
    cargo_metadata_job = -1
  end

  local workspace_root = nil
  if cargo_metadata_job == 0 then
    workspace_root = vim.fn.json_decode(cargo_metadata)['workspace_root']
  end

  return workspace_root
    or manifest_dir
    or utils.root_pattern('rust-project.json')(filename)
    or utils.find_git_ancestor(filename)
end


local prepare = function(opts)
  -- TODO: Test setting a placeholder and changing after the defer
  opts.root_dir = root_dir

  local on_attach = opts.on_attach
  opts.on_attach = function()
    on_attach()
    vim.cmd([[
      augroup pluginRustLsp
        autocmd! * <buffer>
        autocmd BufEnter,TextChanged,InsertLeave <buffer> silent! lua require('plugin.inlay').refresh()
      augroup END
    ]])
    require('plugin.inlay').refresh()
    vim.lsp.codelens.refresh()
  end

  return require('plugin.defer_lsp').make_deferred(opts)
end

return {
  prepare = prepare,
}
