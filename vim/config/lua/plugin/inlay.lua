local namespace = vim.api.nvim_create_namespace('mlima.inlay')
local hl = vim.api.nvim_get_hl_id_by_name('LspCodeLens')

local refresh = function()
  vim.lsp.buf_request(
    0,
    'experimental/inlayHints',
    { textDocument = vim.lsp.util.make_text_document_params(), },
    function(err, res, ctx)
      if err then
        return
      end

      vim.api.nvim_buf_clear_namespace(ctx.bufnr, namespace, 0, -1)
      local root = vim.treesitter.get_parser(ctx.bufnr):parse()[1]:root()

      for _, v in ipairs(res) do
        if v.kind == 1 then
          local str = nil
          if v.label:find(': ', 1, true) == 1 then
            local _, start, _, finish = root:named_descendant_for_range(v.position.line, v.position.character - 1, v.position.line, v.position.character - 1):range()
            local var = string.sub(vim.api.nvim_buf_get_lines(ctx.bufnr, v.position.line, v.position.line + 1, false)[1], start + 1, finish)
            str = var .. v.label
          else
            str = '‣' .. v.label
          end
          vim.api.nvim_buf_set_extmark(ctx.bufnr, namespace, v.position.line, 0, { virt_text = {{ str, hl }}, hl_mode = 'combine' })
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
