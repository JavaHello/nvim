require("kide.core.basic")

vim.schedule(function()
  require("kide.core.utils.plantuml").setup()
  require("kide.core.utils.maven").setup()
  require("kide.core.utils.jdtls").setup()
  require("kide.core.utils.pandoc").setup()

  vim.api.nvim_create_user_command("Date", "lua print(os.date())", {})
end)
