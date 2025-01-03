if vim.env["SPRING_BOOT_NVIM_ENABLE"] == "Y" then
  if require("spring_boot.util").is_application_yml_buf(0) then
    require("spring_boot.launch").start(require("kide.lsp.spring-boot").config)
  end
end
