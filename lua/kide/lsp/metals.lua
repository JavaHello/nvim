local M = {}
local metals_config = require("metals").bare_config()
metals_config.settings = {
  showImplicitArguments = true,
}

metals_config.on_attach = function(client, buffer)
  require("kide.core.keybindings").maplsp(client, buffer)
end

M.setup = function()
  local group = vim.api.nvim_create_augroup("kide_metals", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "scala" },
    callback = function()
      require("metals").initialize_or_attach(metals_config)
    end,
  })
  return group
end

return M
