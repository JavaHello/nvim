require('basic')
require('plugins')
require('lsp')
require('keybindings')

-- vim.api.nvim_command('colorscheme gruvbox')
vim.cmd[[ 
colorscheme gruvbox
set background=dark
"  丢失配色, 变为透明
highlight Normal guibg=NONE ctermbg=None
]]
