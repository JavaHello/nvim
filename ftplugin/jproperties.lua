if vim.env["SPRING_BOOT_NVIM_ENABLE"] == "Y" then
  if require("spring_boot.util").is_application_properties_buf(0) then
    vim.lsp.start(require("kide.lsp.spring-boot").config)
  end
end
