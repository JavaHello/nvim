-- setup must be called before loading the colorscheme
-- Default options:

local kgrubox = require("kide.theme.gruvbox")
local overrides = {
  NormalFloat = {
    bg = kgrubox.colors.black3,
  },
  Pmenu = {
    bg = kgrubox.colors.black2,
  },

  -- cmp, wilder
}

require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = overrides,
  dim_inactive = false,
  transparent_mode = false,
})
vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])
