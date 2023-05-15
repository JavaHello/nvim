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
  palette_overrides = {
    dark1 = "#313131",
    dark2 = "#2e2e2e",
  },
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])
