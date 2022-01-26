-- 行号
vim.wo.number = true
vim.wo.relativenumber = true

-- 高亮所在行
vim.wo.cursorline = true

-- 右侧参考线，超过表示代码太长了，考虑换行
-- vim.wo.colorcolumn = "80"


vim.g.encoding = "UTF-8"

vim.o.fileencoding= "UTF-8"
-- jk移动时光标下上方保留8行
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- 缩进配置
vim.o.tabstop=4
vim.bo.tabstop=4
vim.o.softtabstop=4
-- vim.o.softround=true
-- > < 时移动长度
vim.o.shiftwidth=4
vim.bo.shiftwidth=4

vim.cmd('autocmd Filetype lua setlocal ts=2 sw=2 expandtab')

-- 新行对齐当前行，空格替代tab
vim.o.expandtab = true
vim.bo.expandtab = true
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true


-- 使用增强状态栏后不再需要 vim 的模式提示
vim.o.showmode = false

-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true

-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- smaller updatetime
vim.o.updatetime = 300

-- split window 从下边和右边出现
vim.o.splitbelow = true
vim.o.splitright = true

-- 样式
vim.o.background = "dark"
vim.o.termguicolors = true
vim.opt.termguicolors = true

-- 补全增强
vim.o.wildmenu = true


-- vim.g.python_host_prog='/opt/homebrew/bin/python3'
vim.g.python3_host_prog='/opt/homebrew/bin/python3'
