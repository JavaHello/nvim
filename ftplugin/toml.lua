vim.lsp.start(require("kide.lsp.taplo").config)
vim.bo.formatprg = "taplo fmt -"
