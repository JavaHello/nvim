require("kide.core.basic")

vim.defer_fn(function()
  require("kide.core.utils.plantuml").setup()
end, 0)
