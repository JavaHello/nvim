require("kide.core.basic")

vim.schedule(function()
  require("kide.core.utils.plantuml").setup()
  require("kide.core.utils.maven").setup()
end)
