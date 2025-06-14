local yc = require("kide.lsp.yamlls").config
if yc then
  vim.lsp.start(yc)
end

if vim.g.enable_spring_boot == true then
  local c = require("kide.lsp.spring-boot").config
  if c and require("spring_boot.util").is_application_yml_buf(0) then
    vim.lsp.start(c)
  end
end

if vim.g.enable_quarkus == true then
  local qc = require("kide.lsp.quarkus").config
  vim.lsp.start(qc)
  local mc = require("kide.lsp.microprofile").config
  vim.lsp.start(mc)
  local buf = vim.api.nvim_get_current_buf()
  require("microprofile.yaml").registerYamlSchema(buf)
end
