vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

if vim.env["JDTLS_NVIM_ENABLE"] == "Y" then
  local spring_boot = vim.env["SPRING_BOOT_NVIM_ENABLE"] == "Y"
  local jc = require("kide.lsp.jdtls")
  local config
  -- 防止 start_or_attach 重复修改 config
  if jc.init then
    config = {
      cmd = {},
    }
  else
    config = jc.config
    jc.init = true

    if spring_boot then
      vim.list_extend(config["init_options"].bundles, require("spring_boot").java_extensions())
    end
  end
  require("jdtls").start_or_attach(config, { dap = { config_overrides = {}, hotcodereplace = "auto" } })

  if spring_boot then
    require("spring_boot.launch").start(require("kide.lsp.spring-boot").config)
  end
end
