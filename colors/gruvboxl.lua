-- 使用 morhetz/gruvbox
-- nvchad
local dark0_hard = "#1d2021"
local dark0 = "#282828"
local dark0_soft = "#32302f"
local dark1 = "#3c3836"
local dark2 = "#504945"
local dark3 = "#665c54"
local dark4 = "#7c6f64"
local dark4_256 = "#7c6f64"

local dark_ext0 = "#4e4e4e"
local dark_ext1 = "#2e2e2e"
local dark_ext2 = "#2c2c2c"
local dark_ext3 = "#4b4b4b"
local gray_ext0 = "#656565"

local gray_245 = "#928374"
local gray_244 = "#928374"

local light0_hard = "#f9f5d7"
local light0 = "#fbf1c7"
local light0_soft = "#f2e5bc"
local light1 = "#ebdbb2"
local light2 = "#d5c4a1"
local light3 = "#bdae93"
local light4 = "#a89984"
local light4_256 = "#a89984"

local bright_red = "#fb4934"
local bright_green = "#b8bb26"
local bright_yellow = "#fabd2f"
local bright_blue = "#83a598"
local bright_purple = "#d3869b"
local bright_aqua = "#8ec07c"
local bright_orange = "#fe8019"

local neutral_red = "#cc241d"
local neutral_green = "#98971a"
local neutral_yellow = "#d79921"
local neutral_blue = "#458588"
local neutral_purple = "#b16286"
local neutral_aqua = "#689d6a"
local neutral_orange = "#d65d0e"

local faded_red = "#9d0006"
local faded_green = "#79740e"
local faded_yellow = "#b57614"
local faded_blue = "#076678"
local faded_purple = "#8f3f71"
local faded_aqua = "#427b58"
local faded_orange = "#af3a03"

-- 设置高亮
local function hl(theme)
  for k, v in pairs(theme) do
    vim.api.nvim_set_hl(0, k, v)
  end
end
-- 基础颜色
hl({
  NvimLightGrey2 = { fg = light2 },

  Normal = { fg = light2, bg = dark0 },
  CursorLine = { bg = dark_ext1 },
  WildMenu = { fg = bright_red, bg = bright_yellow },

  WinSeparator = { fg = dark_ext3 },
  Pmenu = { fg = light2, bg = dark0 },
  PmenuSel = { fg = dark0, bg = bright_blue },
  PmenuMatch = { bold = true },
  PmenuMatchSel = { bold = true },
  PmenuKind = { link = "Pmenu" },
  PmenuKindSel = { link = "PmenuSel" },
  PmenuExtra = { link = "Pmenu" },
  PmenuExtraSel = { link = "PmenuSel" },
  PmenuSbar = { bg = "#353535" },
  PmenuThumb = { bg = dark_ext3 },
  QuickFixLine = { bg = dark1 },

  NormalFloat = {},
  FloatBorder = { fg = dark_ext0 },
  StatusLine = { bg = dark_ext2, fg = light1 },
  StatusLineNC = { bg = dark_ext2 },

  TabLine = { bg = dark_ext2, fg = gray_ext0 },
  TabLineSel = { fg = light1, bg = dark0 },
  Directory = { fg = bright_blue },
  Title = { fg = bright_blue, bold = true },
  Question = { fg = bright_blue },
  Search = { fg = dark1, bg = bright_yellow },
  Todo = { fg = bright_green },

  MoreMsg = { fg = bright_green },
  ModeMsg = { fg = bright_green },
  ErrorMsg = { fg = bright_red, bg = dark0 },
  WarningMsg = { fg = bright_yellow },

  DiffAdd = { fg = dark0, bg = bright_green },
  DiffChange = { fg = dark0, bg = bright_aqua },
  DiffDelete = { fg = dark0, bg = bright_red },
  DiffText = { fg = dark0, bg = bright_yellow },

  LineNr = { fg = dark_ext3 },

  Type = { fg = bright_yellow },
  PreProc = { fg = bright_yellow },
  Include = { fg = bright_blue },
  Function = { fg = bright_blue },
  Comment = { fg = gray_ext0, italic = true },
  String = { fg = bright_green },
  Statement = { fg = bright_red },
  Constant = { fg = bright_red },
  Special = { fg = bright_aqua },
  Operator = { fg = bright_blue },
  Delimiter = { fg = neutral_orange },
  Identifier = { fg = bright_red },

  Visual = { bg = "#423e3c" },
  Folded = { fg = gray_ext0, bg = dark_ext1 },

  DiagnosticError = { fg = bright_red },
  DiagnosticInfo = { fg = bright_green },
  DiagnosticHint = { fg = "#b4bbc8" },
  DiagnosticWarn = { fg = neutral_yellow },

  ColorColumn = { bg = dark_ext1 },
  Debug = { fg = neutral_yellow },
  ["@variable"] = { fg = light2 },
  ["@variable.member"] = { fg = bright_red },
  ["@punctuation.delimiter"] = { fg = neutral_orange },
  ["@keyword.operator"] = { fg = bright_purple },
  ["@keyword.exception"] = { fg = bright_red },

  ["@markup"] = { link = "Special" },
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },
  ["@markup.heading"] = { fg = bright_blue },
  ["@markup.link"] = { fg = bright_red },

  ["@markup.quote"] = { bg = dark_ext1 },
  ["@markup.list"] = { fg = bright_red },
  ["@markup.link.label"] = { fg = bright_aqua },
  ["@markup.link.url"] = { underline = true, fg = bright_orange },
  ["@markup.raw"] = { fg = bright_orange },

  LspReferenceWrite = { fg = "#e78a4e" },
  LspReferenceText = { fg = "#e78a4e" },

  NvimTreeGitNew = { fg = neutral_yellow },
  NvimTreeFolderIcon = { fg = "#749689" },
  NvimTreeSpecialFile = { fg = neutral_yellow, bold = true },
  NvimTreeIndentMarker = { fg = "#313334" },

  Added = { fg = bright_green },
  Removed = { fg = bright_red },
  Changed = { fg = neutral_yellow },

  diffChanged = { fg = neutral_yellow },
  diffAdded = { fg = bright_green },

  BlinkCmpMenuBorder = { link = "FloatBorder" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
})
