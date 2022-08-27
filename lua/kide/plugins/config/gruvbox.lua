-- setup must be called before loading the colorscheme
-- Default options:

local colors = require("gruvbox.palette")
local overrides = {

  NvimTreeFolderIcon = {
    fg = colors.bright_green,
  },
}

overrides = vim.tbl_extend("force", overrides, require("kide.theme.gruvbox").flat_telescope)

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
vim.cmd[[colorscheme gruvbox]]
