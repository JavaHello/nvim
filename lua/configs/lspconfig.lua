-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

if capabilities.textDocument.foldingRange then
  capabilities.textDocument.foldingRange.dynamicRegistration = false
  capabilities.textDocument.foldingRange.lineFoldingOnly = true
else
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
end

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "gopls", "ast_grep" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

lspconfig.clangd.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

require("kide.lsp.java").setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}
require("spring_boot").setup {
  server = {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  },
}
require("kide.lsp.sonarlint").setup()

-- XML
require("kide.lsp.lemminx").setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- python
require("kide.lsp.pyright").setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- metals
require("kide.lsp.metals").setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- SQL
-- lspconfig.sqls.setup {
--   cmd = { "sqls", "-config", "~/.config/sqls/config.yml" },
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
-- }
