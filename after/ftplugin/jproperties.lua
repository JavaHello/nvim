if vim.g.enable_spring_boot == true then
  local buf = vim.api.nvim_get_current_buf()
  if require("spring_boot.util").is_application_properties_buf(buf) then
    require("kide.lsp.spring-boot").start()
  end
end
