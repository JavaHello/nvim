vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

if vim.env["JDTLS_NVIM_ENABLE"] == "Y" then
  require("jdtls").start_or_attach(
    require("kide.lsp.java").config,
    { dap = { config_overrides = {}, hotcodereplace = "auto" } }
  )
  vim.lsp.start(require("kide.lsp.spring-boot").config)
end
