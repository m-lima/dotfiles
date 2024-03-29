local Job = require('plenary.job')

local active_buffer = '0'
local git_args = nil
local output = ''

local parse = function(git_output)
  if git_output and #git_output > 2 then
    git_output = git_output:sub(1, 2)
    if git_output == '!!' then
      output = '◌'
    elseif git_output == '??' then
      output = ''
    else
      git_output = git_output:gsub('^U', '')
      git_output = git_output:gsub('U$', '')

      git_output = git_output:gsub(' ', '')
      git_output = git_output:gsub('A', '')
      git_output = git_output:gsub('D', '')
      git_output = git_output:gsub('R', '')
      git_output = git_output:gsub('M', '')
      output = git_output
    end
  else
    output = ''
  end
end

local refresh = function()
  if git_args then
    Job:new({
      command = 'git',
      args = git_args,
      on_exit = function(job, status)
        if status == 0 then
          parse(job:result()[1])
        else
          output = ''
        end
      end,
    }):start()
  end
end

local deep_refresh = function()
  active_buffer = tostring(vim.api.nvim_get_current_buf())
  if vim.bo.readonly or #vim.fn.expand('%') == 0 then
    git_args = nil
    output = ''
  else
    git_args = { '-C', vim.fn.expand('%:h'), 'status', '--porcelain', '--ignored', '--', vim.fn.expand('%:t') }
    refresh()
  end
end

local git_status = require('lualine.component'):extend()

function git_status:init(options)
  git_status.super.init(self, options)

  local augroup = vim.api.nvim_create_augroup('pluginLualineGitstatus', { clear = true })
  vim.api.nvim_create_autocmd(
    'BufEnter',
    {
      group = augroup,
      pattern = '*',
      callback = deep_refresh,
      desc = 'Perform a deep refresh of the git status',
    }
  )
  vim.api.nvim_create_autocmd(
    'BufWritePre',
    {
      group = augroup,
      pattern = '*',
      callback = refresh,
      desc = 'Perform a shallow refresh of the git status',
    }
  )
  deep_refresh()
end

function git_status:update_status()
  if vim.g.actual_curbuf ~= nil and active_buffer ~= vim.g.actual_curbuf then
    deep_refresh()
  end
  return output
end

return git_status

-- -------------------------------------------------
--          [AMD]   not updated
-- M        [ MD]   updated in index
-- A        [ MD]   added to index
-- D                deleted from index
-- R        [ MD]   renamed in index
-- C        [ MD]   copied in index
-- [MARC]           index and work tree matches
-- [ MARC]     M    work tree changed since index
-- [ MARC]     D    deleted in work tree
-- [ D]        R    renamed in work tree
-- [ D]        C    copied in work tree
-- -------------------------------------------------
-- D           D    unmerged, both deleted
-- A           U    unmerged, added by us
-- U           D    unmerged, deleted by them
-- U           A    unmerged, added by them
-- D           U    unmerged, deleted by us
-- A           A    unmerged, both added
-- U           U    unmerged, both modified
-- -------------------------------------------------
-- ?           ?    untracked
-- !           !    ignored
-- -------------------------------------------------
