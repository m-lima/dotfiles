local map = require('script.helper').map

vim.highlight.create('mlima_neotree_cursor', { guifg = 1, ctermfg = 1, guibg = 1, ctermbg = 1, blend = 100 })

local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr)
      local actions = require "telescope.actions"
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require "telescope.actions.state"
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if (filename == nil) then
          filename = selection[1]
        end
        require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
      end)
      return true
    end
  }
end

vim.g.neo_tree_remove_legacy_commands = 1

require('neo-tree').setup({
  close_if_last_window = true,
  window = {
    position = 'left',
    width = 40,
    popup = {
      position = {
        row = 0,
        col = 0,
      },
      border = {
        style = 'none',
      },
      size = function()
        return {
          width = 40,
          height = vim.o.lines - vim.o.cmdheight - 1,
        }
      end,
    },
    mappings = {
      ['<space>'] = '',
      ['<2-LeftMouse>'] = '',
      ['S'] = '',
      ['s'] = '',
      ['t'] = '',
      ['C'] = '',
      ['o'] = 'open',
      ['<C-s>'] = 'open_split',
      ['<C-v>'] = 'open_vsplit',
      ['<C-t>'] = 'open_tabnew',
      ['h'] = 'close_node',
      ['l'] = 'open',
    },
  },
  filesystem = {
    filtered_items = {
      visible = true,
    },
    follow_current_file = true,
    window = {
      mappings = {
        ['<leader>p'] = 'telescope_find',
        ['?'] = 'telescope_rg',
      },
    },
    commands = {
      telescope_find = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        require('telescope.builtin').find_files(getTelescopeOpts(state, path))
      end,
      telescope_rg = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
      end,
    },
  },
  event_handlers = {
    {
      event = 'neo_tree_buffer_enter',
      handler = function()
        vim.opt.guicursor:append('a:mlima_neotree_cursor')
      end
    },
    {
      event = 'neo_tree_buffer_leave',
      handler = function()
        vim.opt.guicursor:remove('a:mlima_neotree_cursor')
      end
    },
  },
})

map('n', '<leader>n', '<cmd>Neotree toggle float reveal<CR>')
map('n', '<leader>N', '<cmd>Neotree focus left reveal<CR>')
map('n', '<leader><leader>n', '<cmd>Neotree show toggle left reveal<CR>')
