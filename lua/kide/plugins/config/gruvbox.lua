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

overrides = vim.tbl_extend("force", overrides, kgrubox.flat_telescope)

require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = true, -- will make italic comments and special strings
  inverse = true, -- invert background for search, diffs, statuslines and errors
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  contrast = "", -- can be "hard" or "soft"
  overrides = overrides,
})

vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])
