vim.g.mapleader = " "
vim.opt.title = true

vim.opt.clipboard = "unnamedplus"

-- 行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.ruler = false

-- 高亮所在行
vim.wo.cursorline = true

-- 右侧参考线，超过表示代码太长了，考虑换行
-- vim.wo.colorcolumn = "80"

-- 边搜索边高亮
vim.o.incsearch = true
-- 忽悠大小写
vim.o.ignorecase = true
-- 智能大小写
vim.o.smartcase = true

vim.g.encoding = "UTF-8"

vim.o.fileencoding = "UTF-8"
-- jk移动时光标下上方保留8行
vim.o.scrolloff = 3
vim.o.sidescrolloff = 3

-- 缩进配置
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
-- vim.o.softround=true
-- > < 时移动长度
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4

local autocmd = vim.api.nvim_create_autocmd
autocmd("FileType", {
  pattern = {
    "lua",
    "javascript",
    "json",
    "css",
    "html",
    "xml",
    "yaml",
    "http",
    "markdown",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- vim.cmd("autocmd Filetype lua setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype js setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype javascript setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype json setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype css setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype html setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype xml setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype yaml setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype http setlocal ts=2 sw=2 expandtab")
-- vim.cmd("autocmd Filetype markdown setlocal ts=2 sw=2 expandtab")

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
vim.o.updatetime = 240

-- split window 从下边和右边出现
vim.o.splitbelow = false
vim.o.splitright = true

-- 样式
vim.opt.background = "dark"
vim.opt.termguicolors = true

-- 补全增强
vim.o.wildmenu = true

vim.opt.confirm = true

-- vim.g.python_host_prog='/opt/homebrew/bin/python3'
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

vim.opt.list = true
vim.opt.cul = true -- cursor line

vim.opt.timeoutlen = 400

-- 始终显示符号列
vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"

vim.cmd([[
if exists('g:neovide')
    " let g:neovide_refresh_rate=60
    let g:neovide_cursor_vfx_mode = "railgun"
    set guifont=Hack\ Nerd\ Font\ Mono,Hack:h13
    " let g:neovide_transparency=1
    " let g:neovide_fullscreen=v:true
    " let g:neovide_remember_window_size = v:true
    let g:neovide_input_use_logo=v:true
    let g:neovide_profiler = v:false
else
endif
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" set grepprg=rg\ --vimgrep
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
" set grepformat^=%f:%l:%c:%m
set grepformat=%f:%l:%c:%m,%f:%l:%m
]])
