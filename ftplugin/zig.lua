if vim.fn.executable("zls") == 1 then
  vim.lsp.start(require("kide.lsp.zls").config)
end
