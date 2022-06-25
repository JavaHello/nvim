local present, impatient = pcall(require, "impatient")

if present then
	impatient.enable_profile()
end

require("core.basic")
require("plugins")
vim.defer_fn(function()
	require("lsp")
end, 0)

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
