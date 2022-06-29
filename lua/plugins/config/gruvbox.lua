-- setup must be called before loading the colorscheme
-- Default options:
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
	contrast = "soft", -- can be "hard" or "soft"
	overrides = {},
})
