vim.lsp.start(require("kide.lsp.lua-ls").config)

vim.bo.formatprg = "stylua -"
