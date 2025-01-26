local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "gopls",
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
  single_file_support = true,
  settings = {
    gopls = {
      analyses = {
        -- https://staticcheck.dev/docs/checks/#SA5008
        -- Invalid struct tag
        SA5008 = true,
        -- Incorrect or missing package comment
        ST1000 = true,
        -- Incorrectly formatted error string
        ST1005 = true,
      },
      staticcheck = true, -- 启用 staticcheck 检查
    },
  },
  init_options = vim.empty_dict(),
  handlers = {},
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
}

return M
