local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "yamlls",
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_dir = vim.fs.root(0, { ".git" }),
  single_file_support = true,
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
    yaml = {
      validate = true,
      hover = true,
      completion = true,
    },
  },
}
return M
