require('gitsigns').setup({
  preview_config = {
    border = 'none',
  },
})

local Job = require('plenary.job')
local map = require('script.helper').map

-- Navigation
map('n', ']g', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
map('n', '[g', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

-- Actions
map('n', '<leader>gs', '<cmd>Gitsigns stage_hunk<CR>')
map('v', '<leader>gs', '<cmd>Gitsigns stage_hunk<CR>')
map('n', '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>')
map('v', '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>')
map('n', '<leader>gS', '<cmd>Gitsigns stage_buffer<CR>')
map('n', '<leader>gu', '<cmd>Gitsigns undo_stage_hunk<CR>')
map('n', '<leader>gR', '<cmd>Gitsigns reset_buffer<CR>')
map('n', '<leader>gp', '<cmd>Gitsigns preview_hunk<CR>')
map('n', '<leader>gb', '<cmd>lua require("gitsigns").blame_line{full=true}<CR>')
map('n', '<leader>gB', '<cmd>Gitsigns toggle_current_line_blame<CR>')
map('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>')
map('n', '<leader>gD', '<cmd>lua require("gitsigns").diffthis("~")<CR>')
map('n', '<leader>gm', '<cmd>lua require("config.gitsigns").change_base()<CR>')
map('n', '<leader>gM', '<cmd>Gitsigns reset_base<CR>')
map('n', '<leader><leader>gd', '<cmd>Gitsigns toggle_deleted<CR>')

-- Text objects
map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')

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
      else
        vim.notify('Error while executing `git merge-base`:', vim.log.levels.ERROR)
        print('outter')
        for _, e in ipairs(job:stderr_result()) do
          vim.notify(e, vim.log.levels.ERROR)
        end
      end
    end),
  }):start()
end

return {
  change_base = change_base,
}
