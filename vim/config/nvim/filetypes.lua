local ok, comment = pcall(require, 'Comment.ft')
local set_comment = function() end
if ok then
  set_comment = comment.set
end

vim.filetype.add({
  extension = {
    slint = function(path, bufnr)
      set_comment('slint', { '// %s', '/* %s */' })
      vim.bo[bufnr].commentstring = '// %s'
      return 'slint'
    end,
    qml = function(path, bufnr)
      set_comment('qml', { '// %s', '/* %s */' })
      vim.bo[bufnr].commentstring = '// %s'
      return 'qml'
    end,
  },
})
