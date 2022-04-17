local present, impatient = pcall(require, "impatient")

if present then
   impatient.enable_profile()
end


require('core.basic')
require('plugins')
vim.defer_fn(function ()
  require('lsp')
end, 0)

-- vim.api.nvim_command('colorscheme gruvbox')
vim.cmd[[ 
colorscheme gruvbox
set background=dark
"  丢失配色, 变为透明
" highlight Normal guibg=NONE ctermbg=None
]]
