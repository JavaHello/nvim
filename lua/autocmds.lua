local autocmd = vim.api.nvim_create_autocmd
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

-- https://nvchad.com/docs/recipes
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if
      line > 1
      and line <= vim.fn.line("$")
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd('normal! g`"')
    end
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
    "git",
    "dbui",
    "dbout",
    "httpResult",
    "dap-repl",
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

autocmd("FileType", {
  group = augroup("close_with_q_bd"),
  pattern = {
    "oil",
    "DressingSelect",
    "dap-*",
  },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = event.buf, silent = true })
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("spell"),
  pattern = "*.md",
  command = "setlocal spell spelllang=en_us,cjk",
})

-- outline
autocmd("FileType", {
  group = augroup("OUTLINE"),
  pattern = {
    "OUTLINE",
  },
  callback = function(_)
    vim.api.nvim_set_option_value("signcolumn", "no", { win = vim.api.nvim_get_current_win() })
  end,
})

-- LSP
local function lsp_command(bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "LspIncomingCalls", vim.lsp.buf.incoming_calls, {
    desc = "Lsp incoming calls",
    nargs = 0,
  })
  vim.api.nvim_buf_create_user_command(bufnr, "LspOutgoingCalls", vim.lsp.buf.outgoing_calls, {
    desc = "Lsp outgoing calls",
    nargs = 0,
  })
end
autocmd("LspAttach", {
  group = augroup("lsp_a"),
  callback = function(args)
    local bufnr = args.buf
    lsp_command(bufnr)
  end,
})

autocmd("TermOpen", {
  group = augroup("close_with_q_term"),
  pattern = "*",
  callback = function(event)
    -- mac 下 t 模式执行 bd! dap 终端会导致 nvim 退出
    -- 这里使用 n 模式下执行
    if vim.b[event.buf].q_close == nil or vim.b[event.buf].q_close == true then
      vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = event.buf, silent = true })
    end
  end,
})

require("kide.melspconfig").init_lsp_progress()
