-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "gruvbox",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    DiffAdd = { fg = "#282828", bg = "#b8bb26", ctermfg = 142, ctermbg = 235 },
    DiffChange = { fg = "#282828", bg = "#8ec07c", ctermfg = 108, ctermbg = 235 },
    DiffDelete = { fg = "#282828", bg = "#fb4934", ctermfg = 167, ctermbg = 235 },
    DiffText = { fg = "#282828", bg = "#fabd2f", ctermfg = 214, ctermbg = 235 },

    LspReferenceText = { fg = "orange", bg = "NONE" },
    LspReferenceRead = { fg = "orange", bg = "NONE" },
    LspReferenceWrite = { fg = "orange", bg = "NONE" },
    FloatBorder = { fg = "#4e4e4e", bg = "NONE" },
    NormalFloat = { fg = "NONE", bg = "NONE" },
    CmpBorder = { link = "FloatBorder" },
    CmpDocBorder = { link = "CmpBorder" },
    CmpDoc = { bg = "NONE" },
  },
  statusline = {
    theme = "default",
    order = { "mode", "file", "git", "diagnostics", "%=", "lsp_msg", "%=", "cursor", "lsp", "cwd" },
    modules = {
      lsp_msg = function()
        return ""
      end,
      cursor = "%#St_pos_text# %l:%c ",
      -- 使用 tmux 状态栏查看时间
      -- date = function()
      --   return "%#St_Lsp# " .. os.date "%Y-%m-%d %H:%M:%S "
      -- end,
    },
  },
}
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })

return M
