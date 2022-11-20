vim.api.nvim_create_user_command("CodelldbLoad", function()
  if not vim.g.codelldb_load then
    vim.g.codelldb_load = require("kide.dap.codelldb").setup()
  end
end, {})
