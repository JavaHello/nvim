vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.lsp.start(require("kide.lsp.rust-analyzer").config)
