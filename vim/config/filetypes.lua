vim.filetype.add({
  extension = {
    slint = function(path, bufnr)
      require('Comment.ft').set('slint', { '//%s', '/*%s*/' })
      vim.bo[bufnr].commentstring = '//%s'
      return 'slint'
    end,
    qml = function(path, bufnr)
      require('Comment.ft').set('qml', { '//%s', '/*%s*/' })
      vim.bo[bufnr].commentstring = '//%s'
      return 'qml'
    end,
  },
})
