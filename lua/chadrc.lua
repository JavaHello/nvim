-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "gruvbox",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    -- DiffDelete = { fg = nil, bg = "red" },
    -- DiffAdd = { fg = nil, bg = "green" },
    -- DiffChange = { fg = nil, bg = "blue" },
    -- DiffText = { fg = nil, bg = "blue" },

    LspReferenceText = { fg = "orange", bg = "grey" },
    LspReferenceRead = { fg = "orange", bg = "grey" },
    LspReferenceWrite = { fg = "orange", bg = "grey" },
  },
}
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
return M
