local M = {}

M.setup = function(opt)
  local dap = require("dap")
  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run or Test Target",
      metals = {
        runType = "runOrTestFile",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = {
        runType = "testTarget",
      },
    },
  }
  local metals_config = vim.tbl_deep_extend("keep", require("metals").bare_config(), opt)
  metals_config.settings = {
    testUserInterface = "Test Explorer",
    showImplicitArguments = true,
    excludedPackages = {
      "akka.actor.typed.javadsl",
      "com.github.swagger.akka.javadsl",
    },
  }

  local fidget_available, _ = pcall(require, "fidget")
  if fidget_available then
    metals_config.init_options.statusBarProvider = "off"
  end

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
