local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
-- local ascli = require("kide.plugins.config.ascli-header")

-- Set header
-- dashboard.section.header.val = ascli[math.random(0, #ascli)]
dashboard.section.header.val = {
  " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
  " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
  " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
  " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
  " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
  " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
}
local opt = { noremap = true, silent = true }
-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("<leader>  ff", "  Find File", ":Telescope find_files<CR>", opt),
  dashboard.button("<leader>  fg", "  Find Word  ", ":Telescope live_grep<CR>", opt),
  dashboard.button("<leader>  fp", "  Recent Projects", ":lua require'telescope'.extensions.project.project{ display_type = 'full' }<CR>", opt),
  dashboard.button("<leader>  fo", "  Recent File", ":Telescope oldfiles<CR>", opt),
  dashboard.button("<leader>  ns", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>", opt),
  dashboard.button("<leader>  q ", "  Quit NVIM", ":qa<CR>", opt),
}

-- Send config to alpha
alpha.setup(dashboard.opts)
