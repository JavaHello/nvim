require("kide.core.basic")

vim.schedule(function()
  require("kide.core.utils.plantuml").setup()
  require("kide.core.utils.maven").setup()
  require("kide.core.utils.jdtls").setup()
  require("kide.core.utils.pandoc").setup()
end)
