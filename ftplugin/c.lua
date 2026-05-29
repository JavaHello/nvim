vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
if require("kide.bigfile").bigfile(vim.api.nvim_get_current_buf()) then
  return
end
require("kide.lsp.clangd").start()

if vim.fn.executable("cppcheck") == 1 then
  require("lint").try_lint("cppcheck")
end
