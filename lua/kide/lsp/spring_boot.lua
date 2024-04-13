local M = {}
M.setup = function (opts)
  local config = {
    server = opts
  }
  require('spring_boot').setup(opts)
  
end
return M
