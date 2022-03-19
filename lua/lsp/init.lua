local lsp_installer = require "nvim-lsp-installer"

-- 安装列表
-- https://github.com/williamboman/nvim-lsp-installer#available-lsps
-- { key: 语言 value: 配置文件 }
local servers = {
  sumneko_lua = require "lsp.lua", -- /lua/lsp/lua.lua
  -- jdtls = require "lsp.java", -- /lua/lsp/jdtls.lua
  jsonls = require("lsp.jsonls"),
  clangd = require 'lsp.c',
  tsserver = require("lsp.tsserver"),
  html = require("lsp.html"),
  pyright = require("lsp.pyright"),
  rust_analyzer = require 'lsp.rust_analyzer',
}

-- 自动安装 LanguageServers
for name, _ in pairs(servers) do
  local server_available, server = lsp_installer.get_server(name)
  if server_available then
    if not server:is_installed() then
      print("Installing " .. name)
      vim.notify(string.format("Installing [%s] server", name), vim.log.levels.INFO)
      server:install()
    end
  end
end

 -- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- 没有确定使用效果参数
-- capabilities.textDocument.completion.completionItem.snippetSupport = true

lsp_installer.on_server_ready(function(server)
  local m = servers[server.name]
  local opts = m.config;
  if opts then
    opts.on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
      -- 绑定快捷键
      require('keybindings').maplsp(buf_set_keymap)
      if m.on_attach then
        m.on_attach(client, bufnr)
      end
      -- vim.notify(string.format("Starting [%s] server", server.name), vim.log.levels.INFO)
    end
    opts.flags = {
      debounce_text_changes = 150,
    }
    opts.capabilities = capabilities;
  end

  if server.name == "rust_analyzer" then
    -- Initialize the LSP via rust-tools instead
    require("rust-tools").setup {
      -- The "server" property provided in rust-tools setup function are the
      -- settings rust-tools will provide to lspconfig during init.            -- 
      -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
      -- with the user's own settings (opts).
      dap = m.dap, 
      server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
    }
    server:attach_buffers()
    -- Only if standalone support is needed
    require("rust-tools").start_standalone_if_required()
  else
    server:setup(opts)
  end
end)

-- LSP 相关美化参考 https://github.com/NvChad/NvChad
local function lspSymbol(name, icon)
  local hl = "DiagnosticSign" .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

lspSymbol("Error", "")
lspSymbol("Info", "")
lspSymbol("Hint", "")
lspSymbol("Warn", "")

vim.diagnostic.config {
  virtual_text = {
    prefix = "",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "single",
})

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
