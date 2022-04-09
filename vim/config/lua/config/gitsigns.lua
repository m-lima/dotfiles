require('gitsigns').setup({
  preview_config = {
    border = 'none',
  },
})

local map = require('script.helper').map

-- Navigation
map('n', ']g', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
map('n', '[g', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

-- Actions
map('n', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
map('v', '<leader>gs',         '<cmd>Gitsigns stage_hunk<CR>')
map('n', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
map('v', '<leader>gr',         '<cmd>Gitsigns reset_hunk<CR>')
map('n', '<leader>gS',         '<cmd>Gitsigns stage_buffer<CR>')
map('n', '<leader>gu',         '<cmd>Gitsigns undo_stage_hunk<CR>')
map('n', '<leader>gR',         '<cmd>Gitsigns reset_buffer<CR>')
map('n', '<leader>gp',         '<cmd>Gitsigns preview_hunk<CR>')
map('n', '<leader>gb',         '<cmd>lua require("gitsigns").blame_line{full=true}<CR>')
map('n', '<leader>gB',         '<cmd>Gitsigns toggle_current_line_blame<CR>')
map('n', '<leader>gd',         '<cmd>Gitsigns diffthis<CR>')
map('n', '<leader>gD',         '<cmd>lua require("gitsigns").diffthis("~")<CR>')
map('n', '<leader>gm',         '<cmd>lua require("config.gitsigns").change_base()<CR>')
map('n', '<leader>gM',         '<cmd>Gitsigns reset_base<CR>')
map('n', '<leader><leader>gd', '<cmd>Gitsigns toggle_deleted<CR>')

-- Text objects
map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')

local handle_job_data = function(data)
  if not data then
    return nil
  end
  for i = #data, 1, -1 do
    if data[i] == '' then
      table.remove(data, i)
    end
  end
  if #data < 1 then
    return nil
  end
  return data
end

local change_base = function(base, head)
  local lines = {}
  local error = ''

  local on_event = function(_, data, event)
    if event == 'stdout' then
      data = handle_job_data(data)
      if not data then
        return
      end

      for i = 1, #data do
        table.insert(lines, data[i])
      end
    elseif event == 'stderr' then
      data = handle_job_data(data)
      if not data then
        return
      end

      for _, line in ipairs(data) do
        error = error .. '\n' .. line
      end
    elseif event == 'exit' then
      if #error > 0 then
        vim.notify('Error during running a job:\n' .. error, vim.log.levels.ERROR)
      else
        require('gitsigns').change_base(lines[1])
      end
    end
  end

  if not base or type(base) ~= 'string' or #base == 0 then
    base = 'master'
  end

  if not head or type(head) ~= 'string' or #head == 0 then
    head = 'HEAD'
  end

  vim.fn.jobstart('git merge-base ' .. base .. ' ' .. head, {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return {
  change_base = change_base,
}
