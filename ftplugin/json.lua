vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2

vim.lsp.start(require("kide.lsp.jsonls").config)
