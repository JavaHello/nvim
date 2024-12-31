local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "taplo",
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_dir = vim.fs.root(0, { "package.json", ".git" }) or vim.uv.cwd(),
  single_file_support = true,
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {
    taplo = {},
  },
}

return M
