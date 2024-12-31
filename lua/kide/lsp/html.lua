local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "html",
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_dir = vim.fs.root(0, { "package.json", ".git" }) or vim.uv.cwd(),
  single_file_support = true,
  settings = {
    html = {},
  },
  init_options = {
    provideFormatter = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
}

return M
