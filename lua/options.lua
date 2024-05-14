require "nvchad.options"

vim.g.mapleader = " "
vim.opt.title = true
vim.opt.exrc = true
vim.opt.secure = false
vim.opt.ttyfast = true

vim.opt_global.jumpoptions = "stack"

-- 高亮所在行
vim.opt.cursorline = true
vim.o.cursorlineopt = "number,line"

-- 菜单最多显示20行
vim.opt.pumheight = 20

vim.opt.updatetime = 300
vim.opt.timeout = true
vim.opt.timeoutlen = 450

vim.opt.confirm = true

-- 禁用 netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt_global.encoding = "UTF-8"

vim.opt.fileencoding = "UTF-8"

-- 当文件被外部程序修改时，自动加载
vim.opt.autoread = true

-- split window 从下边和右边出现
vim.opt.splitbelow = false
vim.opt.splitright = true

vim.opt_global.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt_global.grepformat = "%f:%l:%c:%m,%f:%l:%m"

vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldnestmax = 10
-- 默认不要折叠
vim.opt.foldenable = false
vim.opt.foldlevel = 1

-- toggle invisible characters
vim.opt.list = true
-- vim.opt.listchars = {
--   tab = "→ ",
--   eol = "¬",
--   trail = "⋅",
--   extends = "❯",
--   precedes = "❮",
-- }

-- jk移动时光标下上方保留8行
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3
