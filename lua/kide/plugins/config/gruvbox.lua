local transparent_mode = false
local overrides = {}
if transparent_mode then
  overrides.Pmenu = {
    bg = "none",
  }
end
require("gruvbox").setup({
  transparent_mode = transparent_mode,
})
vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])
