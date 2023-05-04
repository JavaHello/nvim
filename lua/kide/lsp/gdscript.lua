local M = {}
M.setup = function(opt)
  require("lspconfig").gdscript.setup(opt)
end

return M
