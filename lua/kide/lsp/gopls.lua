local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "gopls",
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
  single_file_support = true,
  settings = vim.empty_dict(),
  init_options = vim.empty_dict(),
  handlers = {},
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
}

return M
