local map = require('util').map

local M = {}

local namespace = vim.api.nvim_create_namespace('mlima.breadcrumbs')

local default_config = {
  close = '<Esc>',
  select_left = { 'h', '<Left>' },
  select_right = { 'l', '<Right>' },
  open_selected = { 'o', '<CR>' },
}

local prepare_hl = function()
  local visual = vim.api.nvim_get_hl_by_name('Visual', true).background

  vim.api.nvim_set_hl(namespace, 'mlima_breadcrumbs_normal',   { fg = 'white', bg = 'black' })
  vim.api.nvim_set_hl(namespace, 'mlima_breadcrumbs_selected', { fg = 'white', bg = visual })
  vim.api.nvim_set_hl(namespace, 'mlima_breadcrumbs_selected_start',   { fg = 'black', bg = visual })
  vim.api.nvim_set_hl(namespace, 'mlima_breadcrumbs_selected_end', { fg = visual, bg = 'black' })
end

local map_action = function(bufnr, config, action)
  if vim.tbl_islist(config[action]) then
    for _, key in ipairs(config[action]) do
      map('', key, M[action], { buffer = bufnr })
    end
  else
    map('', config[action], M[action], { buffer = bufnr })
  end
end

local prepare_popup = function(config, width)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')

  map_action(bufnr, config, 'close')
  map_action(bufnr, config, 'select_left')
  map_action(bufnr, config, 'select_right')
  map_action(bufnr, config, 'open_selected')

  vim.api.nvim_open_win(bufnr, true, {
    style = 'minimal',
    relative = 'cursor',
    width = width,
    height = 1,
    col = 0,
    row = 1,
  })

  vim.api.nvim_create_autocmd(
    'BufLeave',
    {
      desc = 'Close the breadcrumb popup',
      callback = function()
        require('plugin.breadcrumbs').close()
      end,
      buffer = bufnr,
      nested = true,
      once = true,
    }
  )

  return bufnr
end

local render = function(breadcrumbs)
  vim.api.nvim_buf_clear_namespace(breadcrumbs.bufnr, namespace, 0, -1)

  local stringified = ' ' .. breadcrumbs.names[1]
  local divs = {}
  for i = 2, #breadcrumbs.names do
    table.insert(divs, #stringified + 2)
    if i == breadcrumbs.selected or i == breadcrumbs.selected + 1 then
      stringified = stringified .. '  ' .. breadcrumbs.names[i]
    else
      stringified = stringified .. '  ' .. breadcrumbs.names[i]
    end
  end

  stringified = stringified .. ' '
  vim.api.nvim_buf_set_option(breadcrumbs.bufnr, 'readonly', false)
  vim.api.nvim_buf_set_option(breadcrumbs.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(breadcrumbs.bufnr, 0, 1, false, { stringified })
  vim.api.nvim_buf_set_option(breadcrumbs.bufnr, 'readonly', true)
  vim.api.nvim_buf_set_option(breadcrumbs.bufnr, 'modifiable', false)

  vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_normal', 0, 0, #stringified)
  for _, div in ipairs(divs) do
    vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_normal_reverse', 0, div, div + 2)
  end

  if breadcrumbs.selected == 1 then
    local length = #breadcrumbs.names[1] + 2
    vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_selected', 0, 0, length)
    if #breadcrumbs.names > 1 then
      vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_selected_end', 0, length, length + 2)
    end
    return
  end

  local start = 0
  for i = 1, breadcrumbs.selected - 1 do
    start = start + #breadcrumbs.names[i] + 5 -- 5 = start space + end space + two-byte delimiter
  end

  local stop = start + #breadcrumbs.names[breadcrumbs.selected] + 2 -- 2 = start space + end space

  vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_selected_start', 0, start - 3, start) -- 3 = two-byte delimiter + start space
  vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_selected', 0, start, stop)
  if breadcrumbs.selected < #breadcrumbs.names then
    vim.api.nvim_buf_add_highlight(breadcrumbs.bufnr, namespace, 'mlima_breadcrumbs_selected_end', 0, stop, stop + 2) -- 2 = two-byte delimiter
  end
end

local create_popup = function(config, names, locations)
  local width = #names - 1
  for _, v in ipairs(names) do
    width = width + vim.api.nvim_strwidth(v) + 2
  end
  local bufnr = prepare_popup(config, width)
  local selected = #names

  return {
    bufnr = bufnr,
    names = names,
    locations = locations,
    selected = selected,
  }
end

local make_location_param = function(location)
  return {
    position = {
      character = location.targetSelectionRange.start.character,
      line = location.targetSelectionRange.start.line,
    },
    textDocument = {
      uri = location.targetUri,
    },
  }
end

local extract_name = function(location)
  local selection = location.targetSelectionRange
  local target = vim.fn.readfile(vim.uri_to_fname(location.targetUri), '', selection['end'].line + 1)
  return string.sub(target[selection['end'].line + 1], selection['start'].character + 1, selection['end'].character)
end

local repeated_response = function(curr, prev)
  return prev and curr
      and curr.targetUri == prev.targetUri
      and curr.targetRange['start'].line == prev.targetRange['start'].line
      and curr.targetRange['start'].character == prev.targetRange['start'].character
      and curr.targetRange['end'].line == prev.targetRange['end'].line
      and curr.targetRange['end'].character == prev.targetRange['end'].character
end

local traverse_parents = function(err, res, ctx)
  local client = ctx.client_id
  local names = {}
  local locations = {}
  local prev = nil
  local max_iterations = 1024

  while max_iterations > 0 and err == nil and res do
    max_iterations = max_iterations - 1

    if vim.tbl_islist(res) then
      res = res[1]
    end

    if not res or repeated_response(res, prev) then
      break
    end
    prev = res

    local name = extract_name(res)
    if name == '' then
      break
    end

    table.insert(names, 1, name)
    table.insert(locations, 1, res)

    res, err = vim.lsp.buf_request_sync(0, 'experimental/parentModule', make_location_param(res), 1000)
    if err then
      vim.notify('Error while building breadcrumbs: ' .. err, vim.log.levels.ERR)
      break
    end
    res = res[client].result
  end

  return names, locations
end

M.show = function(config)
  config = vim.tbl_extend('force', default_config, config or {})
  M.close()
  vim.lsp.buf_request(
    0,
    'experimental/parentModule',
    vim.lsp.util.make_position_params(),
    function(err, res, ctx)
      if err or res == nil or vim.tbl_isempty(res) then
        vim.notify('Could not find parent module', vim.log.levels.INFO)
        return
      end

      local names, locations = traverse_parents(err, res, ctx)

      if #names == 0 then return end
      M.breadcrumbs = create_popup(config, names, locations)

      vim.api.nvim_win_set_hl_ns(0, namespace)
      vim.opt.guicursor:append('a:CursorHidden')

      render(M.breadcrumbs)
    end
  )
end

M.close = function()
  if M.breadcrumbs then
    vim.opt.guicursor:remove('a:CursorHidden')
    vim.api.nvim_win_set_hl_ns(0, 0)

    local breadcrumbs = M.breadcrumbs
    M.breadcrumbs = nil

    vim.cmd('bwipe! ' .. breadcrumbs.bufnr)

    return breadcrumbs
  end
end

M.select_left = function()
  if M.breadcrumbs and M.breadcrumbs.selected > 1 then
    M.breadcrumbs.selected = M.breadcrumbs.selected - 1
    render(M.breadcrumbs)
  end
end

M.select_right = function()
  if M.breadcrumbs and M.breadcrumbs.selected < #M.breadcrumbs.names then
    M.breadcrumbs.selected = M.breadcrumbs.selected + 1
    render(M.breadcrumbs)
  end
end

M.open_selected = function()
  local breadcrumbs = M.close()
  if breadcrumbs then
    vim.lsp.util.jump_to_location(breadcrumbs.locations[breadcrumbs.selected])
  end
end

M.jump_to_parent = function()
  vim.lsp.buf_request(
    0,
    'experimental/parentModule',
    vim.lsp.util.make_position_params(),
    function(err, res)
      if err or res == nil or vim.tbl_isempty(res) then
        vim.notify('Could not find parent module', vim.log.levels.INFO)
        return
      end

      if vim.tbl_islist(res) then
        res = res[1]
      end

      vim.lsp.util.jump_to_location(res)
    end
  )
end

prepare_hl()

map('n', 'gu', M.show)
map('n', 'gU', M.jump_to_parent)

return M
