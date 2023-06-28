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
    local on_attach = scfg.on_attach
    scfg.on_attach = function(client, buffer)
      -- 绑定快捷键
      require("kide.core.keybindings").maplsp(client, buffer)
      if on_attach then
        on_attach(client, buffer)
      end
    end
    scfg.flags = {
      debounce_text_changes = 150,
    }
    scfg.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    if server_name == "clangd" then
      scfg.capabilities.offsetEncoding = { "utf-16" }
    end
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
      on_attach = function(client, buffer)
        -- 绑定快捷键
        require("kide.core.keybindings").maplsp(client, buffer)
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

-- LspAttach 事件

vim.api.nvim_create_augroup("LspAttach_inlay_hint", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlay_hint",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.buf.inlay_hint(bufnr, true)
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
      require("nvim-navic").attach(client, bufnr)
    end
  end,
})

-- 文档格式化
local function markdown_format(input)
  if input then
    input = string.gsub(input, '%[([%a%$_]?[%.%w%(%),\\_%[%]%s :%-@"]*)%]%(file:/[^%)]+%)', function(i1)
      return "`" .. i1 .. "`"
    end)
    input = string.gsub(input, '%[([%a%$_]?[%.%w%(%),\\_%[%]%s :%-@"]*)%]%(jdt://[^%)]+%)', function(i1)
      return "`" .. i1 .. "`"
    end)
  end
  return input
end

local function split_lines(value)
  value = string.gsub(value, "\r\n?", "\n")
  return vim.split(value, "\n", { plain = true })
end
local function convert_input_to_markdown_lines(input, contents)
  contents = contents or {}
  -- MarkedString variation 1
  if type(input) == "string" then
    input = markdown_format(input)
    vim.list_extend(contents, split_lines(input))
  else
    assert(type(input) == "table", "Expected a table for Hover.contents")
    -- MarkupContent
    if input.kind then
      -- The kind can be either plaintext or markdown.
      -- If it's plaintext, then wrap it in a <text></text> block

      -- Some servers send input.value as empty, so let's ignore this :(
      local value = input.value or ""

      if input.kind == "plaintext" then
        -- wrap this in a <text></text> block so that stylize_markdown
        -- can properly process it as plaintext
        value = string.format("<text>\n%s\n</text>", value)
      end

      -- assert(type(value) == 'string')
      vim.list_extend(contents, split_lines(value))
      -- MarkupString variation 2
    elseif input.language then
      -- Some servers send input.value as empty, so let's ignore this :(
      -- assert(type(input.value) == 'string')
      table.insert(contents, "```" .. input.language)
      vim.list_extend(contents, split_lines(input.value or ""))
      table.insert(contents, "```")
      -- By deduction, this must be MarkedString[]
    else
      -- Use our existing logic to handle MarkedString
      for _, marked_string in ipairs(input) do
        convert_input_to_markdown_lines(marked_string, contents)
      end
    end
  end
  if (contents[1] == "" or contents[1] == nil) and #contents == 1 then
    return {}
  end
  return contents
end

local function jhover(_, result, ctx, c)
  c = c or {}
  c.focus_id = ctx.method
  c.stylize_markdown = true
  if not (result and result.contents) then
    vim.notify("No information available")
    return
  end
  local markdown_lines = convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    vim.notify("No information available")
    return
  end
  local b, w = vim.lsp.util.open_floating_preview(markdown_lines, "markdown", c)
  return b, w
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(jhover, lsp_ui.hover_actions)
local source = require("cmp_nvim_lsp.source")
source.resolve = function(self, completion_item, callback)
  -- client is stopped.
  if self.client.is_stopped() then
    return callback()
  end

  -- client has no completion capability.
  if not self:_get(self.client.server_capabilities, { "completionProvider", "resolveProvider" }) then
    return callback()
  end

  self:_request("completionItem/resolve", completion_item, function(_, response)
    -- print(vim.inspect(response))
    if response and response.documentation then
      response.documentation.value = markdown_format(response.documentation.value)
    end
    -- print(vim.inspect(response))
    callback(response or completion_item)
  end)
end
