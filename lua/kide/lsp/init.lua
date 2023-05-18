local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
  },
})

-- 安装列表
-- https://github.com/williamboman/nvim-lsp-installer#available-lsps
-- { key: 语言 value: 配置文件 }
local server_configs = {
  -- sumneko_lua -> lua_ls
  lua_ls = require("kide.lsp.lua_ls"), -- /lua/lsp/lua.lua
  -- jdtls = require "lsp.java", -- /lua/lsp/jdtls.lua
  -- jsonls = require("lsp.jsonls"),
  clangd = require("kide.lsp.clangd"),
  tsserver = require("kide.lsp.tsserver"),
  html = require("kide.lsp.html"),
  pyright = require("kide.lsp.pyright"),
  rust_analyzer = require("kide.lsp.rust_analyzer"),
  sqlls = require("kide.lsp.sqlls"),
  gopls = require("kide.lsp.gopls"),
  kotlin_language_server = {},
  vuels = {},
  lemminx = require("kide.lsp.lemminx"),
  gdscript = require("kide.lsp.gdscript"),
}

-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- 没有确定使用效果参数
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
local utils = require("kide.core.utils")

-- LSP 进度UI
require("fidget")
require("mason-lspconfig").setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    local lspconfig = require("lspconfig")
    -- tools config
    local cfg = utils.or_default(server_configs[server_name], {})

    -- lspconfig
    local scfg = utils.or_default(cfg.server, {})
    -- scfg = vim.tbl_deep_extend("force", server:get_default_options(), scfg)
    local on_attach = scfg.on_attach
    scfg.on_attach = function(client, buffer)
      -- 绑定快捷键
      require("kide.core.keybindings").maplsp(client, buffer)
      if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, buffer)
      end
      if on_attach then
        on_attach(client, buffer)
      end
    end
    scfg.flags = {
      debounce_text_changes = 150,
    }
    scfg.capabilities = capabilities
    if server_name == "rust_analyzer" then
      -- Initialize the LSP via rust-tools instead
      cfg.server = scfg
      require("rust-tools").setup(cfg)
    elseif server_name == "jdtls" then
      -- ignore
    else
      lspconfig[server_name].setup(scfg)
    end
  end,
})

for _, value in pairs(server_configs) do
  if value.setup then
    value.setup({
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = capabilities,
      on_attach = function(client, buffer)
        -- 绑定快捷键
        require("kide.core.keybindings").maplsp(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, buffer)
        end
      end,
    })
  end
end

-- LSP 相关美化参考 https://github.com/NvChad/NvChad
local function lspSymbol(name, icon)
  local hl = "DiagnosticSign" .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

local lsp_ui = require("kide.lsp.lsp_ui")
lspSymbol("Error", lsp_ui.diagnostics.icons.error)
lspSymbol("Info", lsp_ui.diagnostics.icons.info)
lspSymbol("Hint", lsp_ui.diagnostics.icons.hint)
lspSymbol("Warn", lsp_ui.diagnostics.icons.warning)

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp_ui.hover_actions)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_ui.hover_actions)

-- suppress error messages from lang servers
-- vim.notify = function(msg, log_level)
--   if msg:match "exit code" then
--     return
--   end
--   if log_level == vim.log.levels.ERROR then
--     vim.api.nvim_err_writeln(msg)
--   else
--     vim.api.nvim_echo({ { msg } }, true, {})
--   end
-- end
