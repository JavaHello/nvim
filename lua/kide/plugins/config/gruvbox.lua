-- setup must be called before loading the colorscheme
-- Default options:

local overrides = {}

overrides = vim.tbl_extend("force", overrides, require("kide.theme.telescope"))
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

-- vim.api.nvim_command('colorscheme gruvbox')
vim.cmd([[ 
set background=dark
" g:gruvbox_contrast_dark=hard
" set background=light
" g:gruvbox_contrast_light=medium
colorscheme gruvbox
"  丢失配色, 变为透明
" highlight Normal guibg=NONE ctermbg=None
" autocmd vimenter * hi Normal guibg=#282828
]])
