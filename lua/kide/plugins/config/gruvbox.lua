local transparent_mode = false
local overrides = {}
if transparent_mode then
  overrides.Pmenu = {
    bg = "none",
  }
else
  overrides.NormalFloat = {
    bg = "#313131",
  }
  overrides.Pmenu = {
    bg = "#2e2e2e",
  }
end
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
  transparent_mode = transparent_mode,
})
vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])
