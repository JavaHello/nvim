local M = {}

local me = require("kide.melspconfig")
M.config = require("quarkus.launch").lsp_config({
  root_dir = vim.fs.root(0, { ".git" }),
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
})
return M
