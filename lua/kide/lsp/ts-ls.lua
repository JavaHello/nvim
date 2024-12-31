local M = {}
local me = require("kide.melspconfig")

M.config = {
  name = "ts_ls",
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = me.on_attach,
  on_init = me.on_init,
  root_dir = vim.fs.root(0, { "tsconfig.json", "jsconfig.json", "package.json", ".git" }),
  capabilities = me.capabilities(),
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vim.fs.joinpath(me.global_node_modules(), "@vue", "typescript-plugin"),
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  settings = {
    ts_ls = {},
  },
  single_file_support = true,
}
return M
