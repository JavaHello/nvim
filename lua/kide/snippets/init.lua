local M = {}

M.setup = function()
  require("kide.snippets.c")
  require("kide.snippets.java")
  require("luasnip.loaders.from_vscode").lazy_load({
    include = { "go", "c", "python", "sh", "json", "lua", "gitcommit", "sql", "html" },
  })
end

return M
