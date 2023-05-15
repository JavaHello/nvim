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
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- 右侧参考线，超过表示代码太长了，考虑换行
vim.opt.colorcolumn = "120"

-- 边搜索边高亮
vim.opt.incsearch = true
-- 忽悠大小写
vim.opt.ignorecase = true
-- 智能大小写
vim.opt.smartcase = true

vim.opt_global.encoding = "UTF-8"

vim.opt.fileencoding = "UTF-8"
-- jk移动时光标下上方保留8行
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3

-- 缩进配置
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
-- > < 时移动长度
vim.opt.shiftwidth = 4

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
autocmd("FileType", {
  pattern = {
    "gd",
    "gdscript",
    "gdscript3",
  },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- 新行对齐当前行，空格替代tab
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- 使用增强状态栏后不再需要 vim 的模式提示
vim.opt.showmode = false

-- 当文件被外部程序修改时，自动加载
vim.opt.autoread = true

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
-- smaller updatetime
vim.opt.updatetime = 300

-- split window 从下边和右边出现
vim.opt.splitbelow = false
vim.opt.splitright = true

-- 样式
vim.opt.background = "dark"
vim.opt.termguicolors = true

-- 补全增强
vim.opt.wildmenu = true

vim.opt.confirm = true

-- vim.g.python_host_prog='/opt/homebrew/bin/python3'
-- vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

vim.opt.list = true
vim.opt.cul = true -- cursor line

vim.opt.timeout = true
vim.opt.timeoutlen = 450

vim.opt.mouse = "a"

-- 默认不要折叠
-- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99

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

--- see https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local function augroup(name)
  return vim.api.nvim_create_augroup("kide" .. name, { clear = true })
end
-- Highlight on yank
autocmd({ "TextYankPost" }, {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "checkhealth",
    "fugitive",
    "gitcommit",
    "git",
    "dbui",
    "dbout",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

autocmd({ "BufReadCmd" }, {
  group = augroup("git_close_with_q"),
  pattern = "fugitive://*",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- toggle_term
autocmd("FileType", {
  group = augroup("toggle_term"),
  pattern = {
    "toggleterm",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "tt", ":ToggleTerm<CR>", { buffer = event.buf, silent = true })
  end,
})
