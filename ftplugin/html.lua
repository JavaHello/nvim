vim.lsp.start(require("kide.lsp.html").config)
vim.bo.formatprg = "prettier --stdin-filepath %:p"
