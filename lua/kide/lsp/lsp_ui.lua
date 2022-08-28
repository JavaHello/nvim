local M = {}
M.symbol_map = {
  Text = { icon = "" },
  Method = { icon = "", hl = "TSMethod" },
  Function = { icon = "", hl = "TSFunction" },
  Constructor = { icon = "", hl = "TSConstructor" },
  Field = { icon = "ﰠ", hl = "TSField" },
  Variable = { icon = "", hl = "TSConstant" },
  Class = { icon = "ﴯ", hl = "TSType" },
  Interface = { icon = "", hl = "TSType" },
  Module = { icon = "", hl = "TSNamespace" },
  Property = { icon = "ﰠ", hl = "TSMethod" },
  Unit = { icon = "塞" },
  Value = { icon = "" },
  Enum = { icon = "", hl = "TSType" },
  Keyword = { icon = "" },
  Snippet = { icon = "" },
  Color = { icon = "" },
  File = { icon = "", hl = "TSURI" },
  Reference = { icon = "" },
  Folder = { icon = "" },
  EnumMember = { icon = "", hl = "TSField" },
  Constant = { icon = "", hl = "TSConstant" },
  Struct = { icon = "פּ", hl = "TSType" },
  Event = { icon = "", hl = "TSType" },
  Operator = { icon = "", hl = "TSOperator" },
  TypeParameter = { icon = "", hl = "TSParameter" },
  ---------------------------------------------------------
  Namespace = { icon = "", hl = "TSNamespace" },
  Package = { icon = "", hl = "TSNamespace" },
  String = { icon = "", hl = "TSString" },
  Number = { icon = "", hl = "TSNumber" },
  Boolean = { icon = "", hl = "TSBoolean" },
  Array = { icon = "", hl = "TSConstant" },
  Object = { icon = "", hl = "TSType" },
  Key = { icon = "", hl = "TSType" },
  Null = { icon = "ﳠ", hl = "TSType" },
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

return M
