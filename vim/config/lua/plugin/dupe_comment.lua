-- Duplicate and comment
local map = require('util').map

map('v', 'gp',  [[:copy '><CR>'>+1<cmd>lua require('Comment.api').comment.linewise('v')<CR>]])
map('n', 'gpp', '<cmd>.copy .<CR>k<cmd>lua require("Comment.api").comment.linewise.current()<CR>j')
map('n', 'gp',  [[<cmd>lua vim.api.nvim_set_option('operatorfunc', "v:lua.require'plugin.dupe_comment'.dupe")<CR>g@]])

return {
  dupe = function(motion)
    if motion ~= 'line' then
      vim.notify('dupe_comment only works linewise', vim.log.levels.INFO)
      return
    end

    local range = { vim.api.nvim_buf_get_mark(0, '[')[1], vim.api.nvim_buf_get_mark(0, ']')[1] }
    local lines = vim.api.nvim_buf_get_lines(0, range[1] - 1, range[2], false)
    vim.api.nvim_put(lines, 'l', false, true)
    require('Comment.api').comment.linewise('n')
  end,
}
