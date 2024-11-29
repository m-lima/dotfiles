local nil_ls = {
  filtetypes = {
    'nix'
  },
  settings = {
    ['nil'] = {
      formatting = {
        command = { 'nixfmt' },
      },
    },
  },
}

require('config.lspconfig.register').register('nil_ls', nil_ls)
