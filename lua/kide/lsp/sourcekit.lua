local M = {}
M.setup = function(opt)
  require("lspconfig").sourcekit.setup({
    filetypes = { "swift" },
  })
end

return M
