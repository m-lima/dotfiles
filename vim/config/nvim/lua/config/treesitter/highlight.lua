vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true }),
  pattern = '*',
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      pcall(vim.treesitter.start, args.buf)
    end
  end,
})
