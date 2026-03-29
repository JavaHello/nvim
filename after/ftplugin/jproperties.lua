if vim.g.enable_spring_boot == true then
  local c = require("kide.lsp.spring-boot").config
  if c and require("spring_boot.util").is_application_properties_buf(0) then
    vim.lsp.start(c)
  end
end

if vim.g.enable_quarkus == true then
---@diagnostic disable-next-line: different-requires
  local qc = require("kide.lsp.quarkus").config
  vim.lsp.start(qc)
---@diagnostic disable-next-line: different-requires
  local mc = require("kide.lsp.microprofile").config
  vim.lsp.start(mc)
end
