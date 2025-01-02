local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "cssls",
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  init_options = { provideFormatter = true },
  root_dir = vim.fs.root(0, { "package.json" }),
  single_file_support = true,
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
}

return M
