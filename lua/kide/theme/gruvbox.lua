local M = {}
local colors = {
  white = "#ebdbb2",
  darker_black = "#232323",
  black = "#282828",
  black2 = "#2e2e2e",
  black3 = "#313131",
  gray = "#928374",
  red = vim.g.terminal_color_1 or "#fb4934",
  green = vim.g.terminal_color_2 or "#b8bb26",
  yellow = vim.g.terminal_color_3 or "#fabd2f",
  blue = vim.g.terminal_color_4 or "#83a598",
}
M.colors = colors
local flat_telescope = {

  TelescopeBorder = {
    fg = colors.darker_black,
    bg = colors.darker_black,
  },

  TelescopePromptTitle = {
    fg = colors.black,
    bg = colors.red,
  },
  TelescopePromptPrefix = {
    fg = colors.red,
    bg = colors.darker_black,
  },
  TelescopePromptBorder = {
    fg = colors.darker_black,
    bg = colors.darker_black,
  },
  TelescopePromptNormal = {
    fg = colors.white,
    bg = colors.darker_black,
  },

  TelescopeResultsTitle = {
    fg = colors.black2,
    bg = colors.black2,
  },
  TelescopeResultsBorder = {
    fg = colors.black2,
    bg = colors.black2,
  },
  TelescopeResultsNormal = {
    fg = colors.white,
    bg = colors.black2,
  },

  TelescopeNormal = { bg = colors.darker_black },

  TelescopePreviewTitle = {
    fg = colors.black3,
    bg = colors.green,
  },
  TelescopePreviewBorder = {
    fg = colors.black3,
    bg = colors.black3,
  },
  TelescopePreviewNormal = {
    fg = colors.white,
    bg = colors.black3,
  },

  TelescopeSelection = { bg = colors.black2, fg = colors.yellow },
}

M.load_telescope_highlights = function()
  M.load_highlights(flat_telescope)
end
M.load_highlights = function(hl_groups)
  for hl, col in pairs(hl_groups) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

M.load_which_key_highlights = function()
  local bg
  if not vim.g.transparent_mode then
    bg = colors.black3
  end
  M.load_highlights({
    WhichKeyFloat = { bg = bg },
  })
end

M.load_indent_blankline_highlights = function()
  M.load_highlights({
    IblScope = { fg = colors.red },
  })
end

M.load_noice_highlights = function()
  M.load_highlights({
    NoiceCmdlinePopupBorderCmdline = { fg = colors.yellow, bg = nil },
    NoiceCmdlinePopupBorderFilter = { fg = colors.yellow, bg = nil },
    NoiceCmdlinePopupBorderHelp = { fg = colors.yellow, bg = nil },
    NoiceCmdlinePopupBorderInput = { fg = colors.yellow, bg = nil },
    NoiceCmdlinePopupBorderLua = { fg = colors.yellow, bg = nil },
    NoiceCmdlinePopupBorderSearch = { fg = colors.yellow, bg = nil },
    NoiceConfirmBorder = { fg = colors.yellow, bg = nil },

    NoiceCmdlinePopupTitle = { fg = colors.yellow, bg = nil },

    NoiceCmdlineIconCmdline = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconFilter = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconHelp = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconInput = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconLua = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconSearch = { fg = colors.yellow, bg = nil },
  })
end

local load_nvim_ui_highlights = function()
  M.load_highlights({
    NormalFloat = { fg = colors.white, bg = colors.black },
    FloatBorder = { fg = colors.white, bg = nil },
  })
end
if not vim.g.transparent_mode then
  load_nvim_ui_highlights()
end

local load_win_bar_highlights = function()
  M.load_highlights({
    WinBar = { fg = colors.white, bg = colors.black },
  })
end
load_win_bar_highlights()

M.load_hydra_highlights = function()
  local bg
  if not vim.g.transparent_mode then
    bg = colors.black3
  end
  M.load_highlights({
    HydraHint = { bg = bg },
    HydraRed = { fg = colors.red },
    HydraBlue = { fg = colors.blue },
    HydraAmaranth = { fg = colors.red },
    HydraTeal = { fg = colors.green },
    HydraPink = { fg = colors.red },
  })
end
M.load_multi_cursor_highlights = function()
  M.load_highlights({
    MultiCursor = { fg = "#ebdbb2", bg = "#cc241d" },
    MultiCursorMain = { fg = "#fbf1c7", bg = "#9d0006" },
  })
end

return M
