local present, impatient = pcall(require, "impatient")

if present then
   impatient.enable_profile()
end

local core_modules = {
   "core.basic",
   "core.keybindings",
}

for _, module in ipairs(core_modules) do
   local ok, err = pcall(require, module)
   if not ok then
      error("Error loading " .. module .. "\n\n" .. err)
   end
end


require('plugins')
require('lsp')

-- vim.api.nvim_command('colorscheme gruvbox')
vim.cmd[[ 
colorscheme gruvbox
set background=dark
"  丢失配色, 变为透明
" highlight Normal guibg=NONE ctermbg=None
]]
