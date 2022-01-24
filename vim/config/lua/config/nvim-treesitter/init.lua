require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
  highlight = {
    enable = true
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "znn",
      node_incremental = "zrn",
      scope_incremental = "zrc",
      node_decremental = "zrm",
    },
  },
})
