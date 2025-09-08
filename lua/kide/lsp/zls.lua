local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "zls",
  cmd = { "zls" },
  filetypes = { "zig" },
  root_dir = vim.fs.root(0, { "build.zig" }),
  single_file_support = true,
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {},
}

return M
