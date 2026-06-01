local need_yaml_ls = true
if vim.g.enable_spring_boot == true then
  local buf = vim.api.nvim_get_current_buf()
  if require("spring_boot.util").is_application_yml_buf(buf) then
    need_yaml_ls = false
    require("kide.lsp.spring-boot").start()
  end
end

if vim.g.enable_quarkus == true then
  ---@diagnostic disable-next-line: different-requires
  local qc = require("kide.lsp.quarkus").config
  vim.lsp.start(qc)
  ---@diagnostic disable-next-line: different-requires
  local mc = require("kide.lsp.microprofile").config
  vim.lsp.start(mc)
  local buf = vim.api.nvim_get_current_buf()
  require("microprofile.yaml").registerYamlSchema(buf)
end

if need_yaml_ls then
  local yc = require("kide.lsp.yamlls").config
  if yc then
    vim.lsp.start(yc)
  end
end
