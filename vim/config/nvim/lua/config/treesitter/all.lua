-- TODO: Remove this once fixed
local ignore_install = {}
if jit.os == 'OSX' and jit.arch == 'arm64' then
  ignore_install = { 'phpdoc' }
end

local ensure_installed = 'all'

require('config.treesitter.setup')(ensure_installed, ignore_install)
