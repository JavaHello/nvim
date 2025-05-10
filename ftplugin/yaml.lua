local c = require("kide.lsp.spring-boot").config
if c and require("spring_boot.util").is_application_yml_buf(0) then
  vim.lsp.start(c)
end
