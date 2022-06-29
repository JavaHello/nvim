local lsp_installer = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")
lsp_installer.setup({
	ensure_installed = {
		"sumneko_lua",
		"clangd",
		"tsserver",
		"html",
		"pyright",
		"rust_analyzer",
		"sqls",
		"gopls",
	},
})

-- 安装列表
-- https://github.com/williamboman/nvim-lsp-installer#available-lsps
-- { key: 语言 value: 配置文件 }
local server_configs = {
	sumneko_lua = require("lsp.sumneko_lua"), -- /lua/lsp/lua.lua
	-- jdtls = require "lsp.java", -- /lua/lsp/jdtls.lua
	-- jsonls = require("lsp.jsonls"),
	clangd = require("lsp.clangd"),
	tsserver = require("lsp.tsserver"),
	html = require("lsp.html"),
	pyright = require("lsp.pyright"),
	rust_analyzer = require("lsp.rust_analyzer"),
	sqls = require("lsp.sqls"),
	gopls = require("lsp.gopls"),
}

-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- 没有确定使用效果参数
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
local utils = require("core.utils")
for _, server in ipairs(lsp_installer.get_installed_servers()) do
	-- tools config
	local cfg = utils.or_default(server_configs[server.name], {})

	-- lspconfig
	local scfg = utils.or_default(cfg.server, {})
	scfg = vim.tbl_deep_extend("force", server:get_default_options(), scfg)
	local on_attach = scfg.on_attach
	scfg.on_attach = function(client, bufnr)
		-- 绑定快捷键
		require("core.keybindings").maplsp(client, bufnr)
		if on_attach then
			on_attach(client, bufnr)
		end
	end
	scfg.flags = {
		debounce_text_changes = 150,
	}
	scfg.capabilities = capabilities
	if server.name == "rust_analyzer" then
		-- Initialize the LSP via rust-tools instead
		cfg.server = scfg
		require("rust-tools").setup(cfg)
	else
		lspconfig[server.name].setup(scfg)
	end
end

-- LSP 相关美化参考 https://github.com/NvChad/NvChad
local function lspSymbol(name, icon)
	local hl = "DiagnosticSign" .. name
	vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

lspSymbol("Error", "")
lspSymbol("Info", "")
lspSymbol("Hint", "")
lspSymbol("Warn", "")

vim.diagnostic.config({
	virtual_text = {
		prefix = "",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})

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
vim.cmd([[
augroup jdtls_lsp
    autocmd!
    autocmd FileType java lua require'lsp.java'.setup()
augroup end
]])
