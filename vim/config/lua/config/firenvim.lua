if vim.g.started_by_firenvim == true then
  vim.g.firenvim_config = {
    localSettings = {
      ['.*'] = {
        takeover = 'never'
      }
    }
  }
  vim.o.laststatus = 0
end
