local M = {}

-- remove obsolete TS* highlight groups https://github.com/nvim-treesitter/nvim-treesitter/pull/3656
M.symbol_map = {
  Text = { icon = "" },
  Method = { icon = "", hl = "@method" },
  Function = { icon = "", hl = "@function" },
  Constructor = { icon = "", hl = "@constructor" },
  Field = { icon = "ﰠ", hl = "@field" },
  Variable = { icon = "", hl = "@constant" },
  Class = { icon = "ﴯ", hl = "@type" },
  Interface = { icon = "", hl = "@type" },
  Module = { icon = "", hl = "@namespace" },
  Property = { icon = "ﰠ", hl = "@method" },
  Unit = { icon = "塞" },
  Value = { icon = "" },
  Enum = { icon = "", hl = "TSType" },
  Keyword = { icon = "" },
  Snippet = { icon = "" },
  Color = { icon = "" },
  File = { icon = "", hl = "@text.uri" },
  Reference = { icon = "" },
  Folder = { icon = "" },
  EnumMember = { icon = "", hl = "@field" },
  Constant = { icon = "", hl = "@constant" },
  Struct = { icon = "פּ", hl = "@type" },
  Event = { icon = "", hl = "@type" },
  Operator = { icon = "", hl = "@operator" },
  TypeParameter = { icon = "", hl = "@parameter" },
  ---------------------------------------------------------
  Namespace = { icon = "", hl = "@namespace" },
  Package = { icon = "", hl = "@namespace" },
  String = { icon = "", hl = "@string" },
  Number = { icon = "", hl = "@number" },
  Boolean = { icon = "", hl = "@boolean" },
  Array = { icon = "", hl = "@constant" },
  Object = { icon = "", hl = "@type" },
  Key = { icon = "", hl = "@type" },
  Null = { icon = "ﳠ", hl = "@type" },
  Component = { icon = "", hl = "@function" },
  Fragment = { icon = "", hl = "@constant" },
}

M.hover_actions = {
  width = 120,
  border = {
    { "╭", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╮", "FloatBorder" },
    { "│", "FloatBorder" },
    { "╯", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╰", "FloatBorder" },
    { "│", "FloatBorder" },
  },
}

M.signs = {
  closed = "",
  opened = "",
}

M.diagnostics = {
  icons = {
    hint = "",
    info = "",
    warning = "",
    error = "",
  },
}
return M
