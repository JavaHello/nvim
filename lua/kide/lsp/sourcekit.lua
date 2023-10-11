local M = {}
M.setup = function(opt)
  require("lspconfig").sourcekit.setup(opt)
end

return M
