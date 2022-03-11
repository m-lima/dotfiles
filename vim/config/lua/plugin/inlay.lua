local namespace = vim.api.nvim_create_namespace('mlima.inlay')
local hl = vim.api.nvim_get_hl_id_by_name('LspCodeLens')

local refresh = function()
  vim.lsp.buf_request(
    0,
    'rust-analyzer/inlayHints',
    { textDocument = vim.lsp.util.make_text_document_params(), },
    function(err, res, ctx)
      if err then
        return
      end

      vim.api.nvim_buf_clear_namespace(ctx.bufnr, namespace, 0, -1)

      for _, v in ipairs(res) do
        if v.kind == 'TypeHint' then
          if v.range.start.line == v.range['end'].line then
            local start = v.range.start
            local finish = v.range['end']
            local var = string.sub(vim.api.nvim_buf_get_lines(ctx.bufnr, start.line, start.line + 1, false)[1], start.character + 1, finish.character)
            local line = start.line
            local str = var .. ': ' .. v.label
            vim.api.nvim_buf_set_extmark(ctx.bufnr, namespace, line, 0, { virt_text = {{ str, hl }}, hl_mode = 'combine' })
          end
        elseif v.kind == 'ChainingHint' then
          local line = v.range['end'].line
          local str = '‣' .. v.label
          vim.api.nvim_buf_set_extmark(ctx.bufnr, namespace, line, 0, { virt_text = {{ str, hl }}, hl_mode = 'combine' })
        end
      end
    end
  )
end

local set_hl_group = function(name)
  if vim.fn.hlexists(name) ~= 0 then
    hl = vim.api.nvim_get_hl_id_by_name(name)
    refresh()
  end
end

return {
  refresh = refresh,
  set_hl_group = set_hl_group,
}
