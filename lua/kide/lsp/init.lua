require("kide.lsp.lsp_ui").init()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
  },
})

-- { key: 语言 value: 配置文件 }
local server_configs = {
  lua_ls = require("kide.lsp.lua_ls"),
  jdtls = require("kide.lsp.java"),
  metals = require("kide.lsp.metals"),
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
  rime_ls = require("kide.lsp.rime_ls"),
  sourcekit = require("kide.lsp.sourcekit"),
  sonarlint = require("kide.lsp.sonarlint"),
  spring_boot = require("kide.lsp.spring_boot"),
  taplo = {
    setup = function(cfg)
      require("lspconfig").taplo.setup(cfg)
    end,
  },
}

local utils = require("kide.core.utils")

require("mason-lspconfig").setup_handlers({
  function(server_name)
    local lspconfig = require("lspconfig")
    -- tools config
    local cfg = utils.or_default(server_configs[server_name], {})
    -- 自定义启动方式
    if cfg.setup then
      return
    end

    -- lspconfig
    local scfg = utils.or_default(cfg.server, {})
    scfg.flags = {
      debounce_text_changes = 150,
    }
    scfg.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    lspconfig[server_name].setup(scfg)
  end,
})

-- 自定义 LSP 启动方式
for _, value in pairs(server_configs) do
  if value.setup then
    value.setup({
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
    })
  end
end

-- LspAttach 事件
vim.api.nvim_create_augroup("LspAttach_keymap", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_keymap",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == "copilot" then
      return
    end
    -- 绑定快捷键
    require("kide.core.keybindings").maplsp(client, bufnr, client.name == "null-ls")
  end,
})

vim.api.nvim_create_augroup("LspAttach_inlay_hint", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlay_hint",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.api.nvim_buf_create_user_command(bufnr, "InlayHint", function()
      vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
    end, {
      nargs = 0,
    })
    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(bufnr, true)
    end
  end,
})

vim.api.nvim_create_augroup("LspAttach_navic", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_navic",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentSymbolProvider then
      vim.opt_local.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
      require("nvim-navic").attach(client, bufnr)
    end
  end,
})

local CLIENT_CACHE = {}
local function clientCache(client_id)
  if not CLIENT_CACHE[client_id] then
    CLIENT_CACHE[client_id] = {
      CursorHold = {},
      CursorHoldI = {},
      CursorMoved = {},
    }
  end
  return CLIENT_CACHE[client_id]
end
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.server_capabilities.documentHighlightProvider then
      if not clientCache(args.data.client_id).CursorHold[bufnr] then
        clientCache(args.data.client_id).CursorHold[bufnr] = vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
      end
      if not clientCache(args.data.client_id).CursorHoldI[bufnr] then
        clientCache(args.data.client_id).CursorHoldI[bufnr] = vim.api.nvim_create_autocmd("CursorHoldI", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
      end
      if not clientCache(args.data.client_id).CursorMoved[bufnr] then
        clientCache(args.data.client_id).CursorMoved[bufnr] = vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.clear_references()
          end,
        })
      end
    end
  end,
})
vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    local bufnr = args.buf
    -- local client = vim.lsp.get_client_by_id(args.data.client_id)
    if clientCache(args.data.client_id).CursorHold[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorHold[bufnr])
      clientCache(args.data.client_id).CursorHold[bufnr] = nil
    end
    if clientCache(args.data.client_id).CursorHoldI[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorHoldI[bufnr])
      clientCache(args.data.client_id).CursorHoldI[bufnr] = nil
    end
    if clientCache(args.data.client_id).CursorMoved[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorMoved[bufnr])
      clientCache(args.data.client_id).CursorMoved[bufnr] = nil
    end
  end,
})
