vim.g.nvim_jdtls = 1
vim.schedule(function()
  require "kide.autocmds"
  require("kide.core.utils").camel_case_init()
  require("kide.core.utils.plantuml").setup()
  require("kide.core.utils.maven").setup()
end)
