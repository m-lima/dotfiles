local iron = require('iron.core')
local view = require('iron.view')
local common = require('iron.fts.common')

iron.setup({
  config = {
    scratch_repl = true,

    repl_definition = {
      sh = {
        command = { "zsh" }
      },
      python = {
        command = { "ipython", "--no-autoindent" },
        format = common.bracketed_paste_python,
        block_dividers = { "# %%", "#%%" },
      },
    },
    repl_filetype = function(bufnr, ft)
      return ft
    end,
    repl_open_cmd = view.bottom(40),
  },
  keymaps = {
    toggle_repl = '<leader>ii',
    restart_repl = '<leader>ir',
    visual_send = '<leader>ie',
    send_motion = '<leader>ie',
    send_file = '<leader>iea',
    send_line = '<leader>iee',
    send_paragraph = '<leader>iep',
    send_until_cursor = '<leader>ieu',
    send_mark = '<leader>iem',
    send_code_block = '<leader>ieb',
    send_code_block_and_move = '<leader>ien',
    mark_motion = '<leader>im',
    mark_visual = '<leader>im',
    remove_mark = '<leader>im',
    cr = '<leader>i<cr>',
    interrupt = '<leader>i<leader>',
    exit = '<leader>iq',
    clear = '<leader>ic',
  },
  highlight = {
    italic = true
  },
  ignore_blank_lines = true,
})
