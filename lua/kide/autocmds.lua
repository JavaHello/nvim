local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("kide" .. name, { clear = true })
end
-- Highlight on yank
autocmd({ "TextYankPost" }, {
  group = augroup "highlight_yank",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "close_with_q",
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
    "git",
    "dbui",
    "dbout",
    "httpResult",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

autocmd({ "BufReadCmd" }, {
  group = augroup "git_close_with_q",
  pattern = "fugitive://*",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup "spell",
  pattern = "*.md",
  command = "setlocal spell spelllang=en_us,cjk",
})
