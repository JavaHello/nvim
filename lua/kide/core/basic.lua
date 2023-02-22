vim.g.mapleader = " "
vim.opt.title = true

vim.opt.clipboard = "unnamedplus"

-- 禁用 netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-- 行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.ruler = false

-- 高亮所在行
vim.wo.cursorline = true

-- 右侧参考线，超过表示代码太长了，考虑换行
vim.wo.colorcolumn = "120"

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
    "lisp",
    "sh",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

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
vim.o.splitbelow = false
vim.o.splitright = true

-- 样式
vim.opt.background = "dark"
vim.opt.termguicolors = true

-- 补全增强
vim.o.wildmenu = true

vim.opt.confirm = true

-- vim.g.python_host_prog='/opt/homebrew/bin/python3'
-- vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

vim.opt.list = true
vim.opt.cul = true -- cursor line

vim.o.timeout = true
vim.opt.timeoutlen = 450

vim.opt.mouse = "a"

-- 默认不要折叠
-- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99

-- Highlight on yank
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = { "*" },
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.opt_global.completeopt = "menu,menuone,noselect"
if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.opt_global.guifont = "Hack Nerd Font Mono,Hack:h13"
  vim.g.neovide_transparency = 1
  vim.g.neovide_fullscreen = true
  vim.g.neovide_input_use_logo = true
  vim.g.neovide_profiler = false
end

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local l = vim.fn.line("'\"")
    if l > 1 and l <= vim.fn.line("$") then
      vim.fn.execute("normal! g'\"")
    end
  end,
})

vim.opt_global.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt_global.grepformat = "%f:%l:%c:%m,%f:%l:%m"
