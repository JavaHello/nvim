vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

if vim.env["JDTLS_NVIM_ENABLE"] == "Y" then
  local jc = require("kide.lsp.jdtls")
  local config
  -- 防止 start_or_attach 重复修复 config
  if jc.init then
    config = {
      cmd = {},
    }
  else
    config = jc.config
    jc.init = true
  end
  require("jdtls").start_or_attach(config, { dap = { config_overrides = {}, hotcodereplace = "auto" } })
  require("spring_boot.launch").start(require("kide.lsp.spring-boot").config)
end
