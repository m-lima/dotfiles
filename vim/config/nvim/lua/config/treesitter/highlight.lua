vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true }),
  pattern = '*',
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      local ok, err = pcall(vim.treesitter.start, args.buf)
      if not ok then
        local msg = string.format("Could not start treesitter: %s", vim.inspect(err))
        vim.notify(msg, vim.log.levels.WARN, { title = "Treesitter" })
      end
    end
  end,
})
