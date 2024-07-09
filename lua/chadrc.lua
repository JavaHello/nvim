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
    CmpDocBorder = { link = "CmpBorder" },
  },
  statusline = {
    theme = "default",
    order = { "mode", "file", "git", "diagnostics", "%=", "lsp_msg", "%=", "cursor", "lsp", "cwd" },
    modules = {
      lsp_msg = function()
        return ""
      end,
      cursor = "%#St_pos_text# %l:%c ",
    },
  },
}
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })

local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = border "CmpBorder",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = border "CmpBorder",
  focusable = false,
  relative = "cursor",
  silent = true,
})

return M
