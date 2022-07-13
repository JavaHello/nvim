local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
-- local ascli = require("kide.plugins.config.ascli-header")

dashboard.leader = "\\"
-- Set header
-- dashboard.section.header.val = ascli[math.random(0, #ascli)]
dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
  "                                                     ",
}
local opt = { noremap = true, silent = true }
-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("<leader>  ff", "  Find File", ":Telescope find_files<CR>", opt),
  dashboard.button("<leader>  fg", "  Find Word  ", ":Telescope live_grep<CR>", opt),
  dashboard.button("<leader>  fp", "  Recent Projects", ":Telescope projects<CR>", opt),
  dashboard.button("<leader>  fo", "  Recent File", ":Telescope oldfiles<CR>", opt),
  dashboard.button("<leader>  ns", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>", opt),
  dashboard.button("<leader>  q ", "  Quit NVIM", ":qa<CR>", opt),
}

-- Set footer
--   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
--   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
--   ```init.lua
--   return require('packer').startup(function()
--       use 'wbthomason/packer.nvim'
--       use {
--           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
--           requires = {'BlakeJC94/alpha-nvim-fortune'},
--           config = function() require("config.alpha") end
--       }
--   end)
--   ```
-- local fortune = require("alpha.fortune")
-- dashboard.section.footer.val = fortune()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
