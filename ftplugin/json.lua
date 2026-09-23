vim.lsp.start(require("kide.lsp.jsonls").config)

vim.bo.formatprg = "jq ."
