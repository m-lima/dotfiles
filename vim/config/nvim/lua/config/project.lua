local telescope = require('telescope')

require('project_nvim').setup({
  patterns = { '.vim/', '.git/', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'build.gradle', 'CMakeLists.txt' }
})

telescope.load_extension('projects')

map('n', '<leader><leader>p', telescope.extensions.projects.projects)

