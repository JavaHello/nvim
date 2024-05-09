-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "gruvbox",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    DiffDelete = { fg = "NONE", bg = "#3c1f1e" },
    DiffAdd = { fg = "NONE", bg = "#32361a" },
    DiffChange = { fg = "NONE", bg = "#0d3138" },
    DiffText = { fg = "yellow", bg = "#282828" },

    LspReferenceText = { fg = "orange", bg = "grey" },
    LspReferenceRead = { fg = "orange", bg = "grey" },
    LspReferenceWrite = { fg = "orange", bg = "grey" },
  },
  statusline = {
    theme = "default",
  },
}
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
return M
