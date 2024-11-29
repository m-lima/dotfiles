local qmlls = {
  filtetypes = {
    'qml', 'qmljq'
  },
}

require('config.lspconfig.register').register('qmlls', qmlls)
