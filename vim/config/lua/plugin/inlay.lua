local namespace = vim.api.nvim_create_namespace('mlima.inlay')
local hl_mark = vim.api.nvim_get_hl_id_by_name('LspCodeLensMark')
local hl_type = vim.api.nvim_get_hl_id_by_name('LspCodeLensType')
local should_display_var_name = true

local get_root = function(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if ok then
    return parser:parse()[1]:root()
  end
end

local get_params = function()
  local params = {
    range = {
      start = {
        character = 0,
        line = 0,
      },
    },
    textDocument = {
      uri = vim.uri_from_bufnr(0),
    },
  }
  params.range['end'] = {
    character = 0,
    line = vim.api.nvim_buf_line_count(0) - 1,
  }
  return params
end

local extract_virtual_text = function(value, root, ctx)
  if value.kind ~= 1 then
    return nil
  end

  local label = value.tooltip

  if not label then
    if type(value.label) == 'table' then
      label = ''
      for _, l in ipairs(value.label) do
        label = label .. l.value
      end
    elseif type(value.label) == 'string' then
      label = value.label
    else
      return nil
    end
  end

  if label:find(': ', 1, true) == 1 then
    local mark = nil
    if root then
      -- Extract variable name from treesitter
      local _, start, _, finish = root
          :named_descendant_for_range(
            value.position.line,
            value.position.character - 1,
            value.position.line,
            value.position.character - 1
          )
          :range()
      mark = {
        string.sub(
          vim.api.nvim_buf_get_lines(ctx.bufnr, value.position.line, value.position.line + 1, false)[1],
          start + 1,
          finish
        ) .. ': ',
        hl_mark
      }
    end

    return {
      mark,
      { label:sub(3), hl_type },
    }
  elseif label:find(' -> ', 1, true) == 1 then
    return {
      { ' ', hl_mark },
      { label:sub(5), hl_type },
    }
  else
    return {
      { '﬋ ', hl_mark },
      { label, hl_type },
    }
  end
end

local refresh = function()
  vim.lsp.buf_request(
    0,
    'textDocument/inlayHint',
    get_params(),
    function(err, res, ctx)
      if err or not res then return end

      if not vim.tbl_islist(res) then
        vim.notify('Unrecognized response: ' .. res, vim.log.levels.ERR)
      end

      vim.api.nvim_buf_clear_namespace(ctx.bufnr, namespace, 0, -1)
      local root = should_display_var_name and get_root(ctx.bufnr)

      for _, v in ipairs(res) do
        local virtual_text = extract_virtual_text(v, root, ctx)

        if virtual_text then
          vim.api.nvim_buf_set_extmark(
            ctx.bufnr,
            namespace,
            v.position.line,
            v.position.character,
            {
              virt_text = virtual_text,
              hl_mode = 'combine'
            }
          )
        end
      end
    end
  )
end

local set_hl_group = function(name, for_mark)
  if vim.fn.hlexists(name) ~= 0 then
    if for_mark then
      hl_mark = vim.api.nvim_get_hl_id_by_name(name)
    else
      hl_type = vim.api.nvim_get_hl_id_by_name(name)
    end
    refresh()
  end
end

local display_var_name = function(enabled)
  if should_display_var_name ~= enabled then
    should_display_var_name = enabled
    refresh()
  end
end

local debug = function()
  local buf = vim.api.nvim_get_current_buf();

  local params = {
    range = {
      start = {
        character = 0,
        line = 0,
      },
    },
    textDocument = {
      uri = vim.uri_from_bufnr(buf),
    },
  }

  params.range['end'] = {
    character = 0,
    line = vim.api.nvim_buf_line_count(buf),
  }

  vim.lsp.buf_request(
    buf,
    'textDocument/inlayHint',
    params,
    function(err, res, ctx)
      if res then
        require('util').float.show({ params = params, res = res })
      else
        require('util').float.show({ params = params, err = err })
      end
    end
  )
end

return {
  refresh = refresh,
  set_hl_group = set_hl_group,
  display_var_name = display_var_name,
  debug = debug,
}
