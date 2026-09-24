local need_yaml_ls = true
if vim.g.enable_spring_boot == true then
  local buf = vim.api.nvim_get_current_buf()
  if require("spring_boot.util").is_application_yml_buf(buf) then
    need_yaml_ls = false
  end
end

if need_yaml_ls then
  local yc = require("kide.lsp.yamlls").config
  if yc then
    vim.lsp.start(yc)
  end
end
