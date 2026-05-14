require("kide.lsp.pyright").init_dap()
vim.lsp.start(require("kide.lsp.pyright").config)
vim.bo.formatprg = "black -q -"
