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
local util = require "lspconfig.util"
-- "ast_grep"
local servers = { "html", "cssls", "gopls", "zls", "jsonls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

local metals_enable = vim.env["METALS_ENABLE"]

if metals_enable == "Y" then
  -- metals
  require("kide.lsp.metals").setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
else
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
end

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

-- SQL
-- lspconfig.sqls.setup {
--   cmd = { "sqls", "-config", "~/.config/sqls/config.yml" },
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
-- }

local function global_node_modules()
  local global_path = ""
  if util.path.exists "/opt/homebrew/" then
    global_path = "/opt/homebrew/lib/node_modules"
  elseif util.path.exists "/usr/local/lib/node_modules" then
    global_path = "/usr/local/lib/node_modules"
  else
    global_path = util.path.join(os.getenv "HOME", ".npm", "lib", "node_modules")
  end
  if not util.path.exists(global_path) then
    vim.notify("Global node_modules not found", vim.log.levels.DEBUG)
  end
  return global_path
end

local function get_typescript_server_path(root_dir)
  local found_ts = ""
  local function check_dir(path)
    found_ts = util.path.join(path, "node_modules", "typescript", "lib")
    if util.path.exists(found_ts) then
      return path
    end
  end
  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    local global_ts = util.path.join(global_node_modules(), "typescript", "lib")
    return global_ts
  end
end

-- 需要安装 Vue LSP 插件
-- npm install -g @vue/language-server
-- npm install -g @vue/typescript-plugin
require("lspconfig").volar.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}

require("lspconfig").ts_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = util.path.join(global_node_modules(), "@vue", "typescript-plugin"),
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = {
    "javascript",
    "typescript",
    "vue",
  },
}
