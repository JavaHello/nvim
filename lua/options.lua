require "nvchad.options"

local fn = vim.fn

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

vim.opt.linespace = 0

-- quickfix 美化
function _G.qftf(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  local limit = 44
  local fnameFmt1, fnameFmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"
  local validFmt = "%s │%5d:%-3d│%s %s"
  local fmt = true
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ""
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = fn.bufname(e.bufnr)
        fmt = true
        if fname == "" then
          fname = "[No Name]"
        else
          fname = fname:gsub("^" .. vim.env.HOME, "~")
        end
        if vim.startswith(fname, "jdt://") then
          local jar, pkg, class = fname:match "^jdt://contents/([^/]+)/([^/]+)/(.+)?"
          fname = "󰧮 " .. class .. "  " .. pkg .. "  " .. jar

          -- 加载 jdt:// 文件
          if vim.fn.bufloaded(e.bufnr) == 0 then
            vim.fn.bufload(e.bufnr)
          end
          fmt = false
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if fmt then
          if #fname <= limit then
            fname = fnameFmt1:format(fname)
          else
            fname = fnameFmt2:format(fname:sub(1 - limit))
          end
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
      str = validFmt:format(fname, lnum, col, qtype, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end

vim.o.qftf = "{info -> v:lua._G.qftf(info)}"

vim.opt.laststatus = 3
vim.opt.splitkeep = "screen"

-- lsp 时常出现 swapfile 冲突提示, 关闭 swapfile
vim.opt.swapfile = false
vim.opt.backup = false

-- see noice
-- vim.opt.cmdheight=0
