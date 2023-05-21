local M = {}
local metals_config = require("metals").bare_config()
metals_config.settings = {
  showImplicitArguments = true,
}

M.setup = function(opt)
  metals_config.on_attach = function(client, buffer)
    if opt.on_attach then
      opt.on_attach(client, buffer)
    end
  end
  local group = vim.api.nvim_create_augroup("kide_metals", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "scala" },
    callback = function()
      require("metals").initialize_or_attach(metals_config)
    end,
  })
end

return M
