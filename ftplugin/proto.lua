if require("kide.bigfile").bigfile(vim.api.nvim_get_current_buf()) then
  return
end
require("kide.lsp.clangd").start()
