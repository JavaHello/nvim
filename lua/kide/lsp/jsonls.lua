local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "jsonls",
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_dir = vim.fs.root(0, { ".git" }),
  single_file_support = true,
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {},
}
return M
