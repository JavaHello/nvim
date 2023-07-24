local M = {}
local lspkind_symbol_map = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
}

-- remove obsolete TS* highlight groups https://github.com/nvim-treesitter/nvim-treesitter/pull/3656
M.symbol_map = {
  Text = { icon = lspkind_symbol_map.Text },
  Method = { icon = lspkind_symbol_map.Method, hl = "@method" },
  Function = { icon = lspkind_symbol_map.Function, hl = "@function" },
  Constructor = { icon = lspkind_symbol_map.Constructor, hl = "@constructor" },
  Field = { icon = lspkind_symbol_map.Field, hl = "@field" },
  Variable = { icon = lspkind_symbol_map.Variable, hl = "@constant" },
  Class = { icon = lspkind_symbol_map.Class, hl = "@type" },
  Interface = { icon = lspkind_symbol_map.Interface, hl = "@type" },
  Module = { icon = lspkind_symbol_map.Module, hl = "@namespace" },
  Property = { icon = lspkind_symbol_map.Property, hl = "@method" },
  Unit = { icon = lspkind_symbol_map.Unit },
  Value = { icon = lspkind_symbol_map.Value },
  Enum = { icon = lspkind_symbol_map.Enum, hl = "TSType" },
  Keyword = { icon = lspkind_symbol_map.Keyword },
  Snippet = { icon = lspkind_symbol_map.Snippet },
  Color = { icon = lspkind_symbol_map.Color },
  File = { icon = lspkind_symbol_map.File, hl = "@text.uri" },
  Reference = { icon = lspkind_symbol_map.Reference },
  Folder = { icon = lspkind_symbol_map.Folder },
  EnumMember = { icon = lspkind_symbol_map.EnumMember, hl = "@field" },
  Constant = { icon = lspkind_symbol_map.Constant, hl = "@constant" },
  Struct = { icon = lspkind_symbol_map.Struct, hl = "@type" },
  Event = { icon = lspkind_symbol_map.Event, hl = "@type" },
  Operator = { icon = lspkind_symbol_map.Operator, hl = "@operator" },
  TypeParameter = { icon = "", hl = "@parameter" },
  ---------------------------------------------------------
  Namespace = { icon = "", hl = "@namespace" },
  Package = { icon = "", hl = "@namespace" },
  String = { icon = "", hl = "@string" },
  Number = { icon = "", hl = "@number" },
  Boolean = { icon = "", hl = "@boolean" },
  Array = { icon = "", hl = "@constant" },
  Object = { icon = "", hl = "@type" },
  Key = { icon = "󰌋", hl = "@type" },
  Null = { icon = "󰟢", hl = "@type" },
  Component = { icon = "󰡀", hl = "@function" },
  Fragment = { icon = "", hl = "@constant" },
}

M.window = {
  winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
}

M.hover_actions = {
  border = {
    { "┌", "FloatBorder" },
    { "─", "FloatBorder" },
    { "┐", "FloatBorder" },
    { "│", "FloatBorder" },
    { "┘", "FloatBorder" },
    { "─", "FloatBorder" },
    { "└", "FloatBorder" },
    { "│", "FloatBorder" },
  },
  style = "fillchars",
  -- Maximal width of the hover window. Nil means no max.
  max_width = 80,

  -- Maximal height of the hover window. Nil means no max.
  max_height = 20,

  -- whether the hover action window gets automatically focused
  -- default: false
  auto_focus = false,
}

M.signs = {
  closed = "",
  opened = "",
}

M.diagnostics = {
  icons = {
    hint = "",
    info = "",
    warning = "",
    error = "",
  },
}

-- LSP 相关美化参考 https://github.com/NvChad/NvChad
local function lspSymbol(name, icon)
  local hl = "DiagnosticSign" .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end
M.init = function()
  local lsp_ui = M
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

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_ui.hover_actions)

  -- 文档格式化
  local function markdown_format(input)
    if input then
      input = string.gsub(input, '%[([%a%$_]?[%.%w%(%)*"+,\\_%[%]%s :%-@<>]*)%]%(file:/[^%)]+%)', function(i1)
        return "`" .. i1 .. "`"
      end)
      input = string.gsub(input, '%[([%a%$_]?[%.%w%(%)*"+,\\_%[%]%s :%-@<>]*)%]%(jdt://[^%)]+%)', function(i1)
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

  local function jhover(_, result, ctx, config)
    config = config or {}
    config.focus_id = ctx.method
    if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
      -- Ignore result since buffer changed. This happens for slow language servers.
      return
    end
    if not (result and result.contents) then
      if config.silent ~= true then
        vim.notify("No information available")
      end
      return
    end
    local markdown_lines = convert_input_to_markdown_lines(result.contents)
    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
    if vim.tbl_isempty(markdown_lines) then
      if config.silent ~= true then
        vim.notify("No information available")
      end
      return
    end
    local bufnr, winnr = vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
    vim.api.nvim_win_set_option(winnr, "winhighlight", lsp_ui.window.winhighlight)
    return bufnr, winnr
  end
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(jhover, lsp_ui.hover_actions)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(function(a, result, ctx, b)
    local bufnr, winnr = vim.lsp.handlers.signature_help(a, result, ctx, b)
    vim.api.nvim_win_set_option(winnr, "winhighlight", lsp_ui.window.winhighlight)
    return bufnr, winnr
  end, lsp_ui.hover_actions)

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
      -- jdtls 文档格式化
      if self.client.name == "jdtls" and response and response.documentation then
        response.documentation.value = markdown_format(response.documentation.value)
      end
      -- print(vim.inspect(response))
      callback(response or completion_item)
    end)
  end
end

return M
