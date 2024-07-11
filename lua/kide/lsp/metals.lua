local M = {}

M.setup = function(opt)
  local metals_config = vim.tbl_deep_extend("keep", require("metals").bare_config(), opt)
  local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  local on_attach = metals_config.on_attach
  metals_config.on_attach = function(client, bufnr)
    if on_attach then
      on_attach(client, bufnr)
    end
    require("metals").setup_dap()

    local create_command = vim.api.nvim_buf_create_user_command
    create_command(bufnr, "MetalsCommands", require("telescope").extensions.metals.commands, {
      nargs = 0,
    })
  end
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = function()
      require("metals").initialize_or_attach(metals_config)
    end,
    group = nvim_metals_group,
  })
end

return M
