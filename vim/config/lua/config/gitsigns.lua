local Job = require('plenary.job')
local map = require('util').map

local change_base = function(base, head)
  if not base or type(base) ~= 'string' or #base == 0 then
    base = 'master'
  end

  if not head or type(head) ~= 'string' or #head == 0 then
    head = 'HEAD'
  end

  Job:new({
    command = 'git',
    args = { 'merge-base', base, head },
    on_exit = vim.schedule_wrap(function(job, status)
      if status == 0 then
        require('gitsigns').change_base(job:result()[1])
        print('Gitsigns comparing ' .. head .. ' to ' .. base)
      else
        vim.notify('Error while executing `git merge-base`:', vim.log.levels.ERROR)
        for _, e in ipairs(job:stderr_result()) do
          vim.notify(e, vim.log.levels.ERROR)
        end
      end
    end),
  }):start()
end

local reset_base = function()
  require('gitsigns').reset_base()
  print('Gitsigns base reset')
end

require('gitsigns').setup({
  preview_config = {
    border = 'none',
  },

  on_attach = function()
    local gitsigns = package.loaded.gitsigns

    -- Navigation
    map('n', ']g',                 gitsigns.next_hunk)
    map('n', '[g',                 gitsigns.prev_hunk)

    -- Actions
    map({'n', 'v'}, '<leader>gs',  gitsigns.stage_hunk)
    map({'n', 'v'}, '<leader>gr',  gitsigns.reset_hunk)
    map('n',        '<leader>gS',  gitsigns.stage_buffer)
    map('n',        '<leader>gu',  gitsigns.undo_stage_hunk)
    map('n',        '<leader>gR',  gitsigns.reset_buffer)
    map('n',        '<leader>gp',  gitsigns.preview_hunk)

    -- Views
    map('n', '<leader><leader>gb', function() gitsigns.blame_line({ full = true }) end)
    map('n', '<leader>gB',         gitsigns.toggle_current_line_blame)
    map('n', '<leader>gd',         gitsigns.diffthis)
    map('n', '<leader>gD',         function() gitsigns.diffthis("~") end)
    map('n', '<leader>gm',         change_base)
    map('n', '<leader>gM',         reset_base)
    map('n', '<leader><leader>gd', gitsigns.toggle_deleted)

    -- Text objects
    map('o', 'ih',                 gitsigns.select_hunk)
    map('x', 'ih',                 gitsigns.select_hunk)
  end,
})

vim.api.nvim_create_user_command(
  'GitBase',
  function (args)
    change_base(unpack(args.fargs))
  end,
  {
    desc = 'Gitsigns base setting',
    nargs = '*',
  }
)

return {
  change_base = change_base,
}
