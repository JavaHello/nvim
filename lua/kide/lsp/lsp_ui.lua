local M = {}
local lspkind_symbol_map = require("lspkind").symbol_map

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

M.hover_actions = {
  width = 120,
  -- border = {
  -- { "╭", "FloatBorder" },
  -- { "─", "FloatBorder" },
  -- { "╮", "FloatBorder" },
  -- { "│", "FloatBorder" },
  -- { "╯", "FloatBorder" },
  -- { "─", "FloatBorder" },
  -- { "╰", "FloatBorder" },
  -- { "│", "FloatBorder" },
  -- },
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
return M
