vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
if require("kide.bigfile").bigfile(vim.api.nvim_get_current_buf()) then
  return
end
vim.lsp.start(require("kide.lsp.clangd").config)
