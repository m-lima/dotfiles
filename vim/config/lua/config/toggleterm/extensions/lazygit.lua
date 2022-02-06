vim.notify('Creating lazygit', vim.log.levels.WARN)
return require('toggleterm.terminal').Terminal:new({
  cmd = 'lazygit',
  direction = 'float',
  hidden = true,
})
