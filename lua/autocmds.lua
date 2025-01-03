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
local CLIENT_CACHE = {}
local function clientCache(client_id)
  if not CLIENT_CACHE[client_id] then
    CLIENT_CACHE[client_id] = {
      CursorHold = {},
      CursorHoldI = {},
      CursorMoved = {},
    }
  end
  return CLIENT_CACHE[client_id]
end
local LSP_COMMAND_CACHE = {}
local function lsp_command(bufnr)
  if LSP_COMMAND_CACHE[bufnr] then
    return
  end
  LSP_COMMAND_CACHE[bufnr] = true
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

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end

    if client.server_capabilities.documentHighlightProvider then
      if not clientCache(args.data.client_id).CursorHold[bufnr] then
        clientCache(args.data.client_id).CursorHold[bufnr] = vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
      end
      if not clientCache(args.data.client_id).CursorHoldI[bufnr] then
        clientCache(args.data.client_id).CursorHoldI[bufnr] = vim.api.nvim_create_autocmd("CursorHoldI", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
      end
      if not clientCache(args.data.client_id).CursorMoved[bufnr] then
        clientCache(args.data.client_id).CursorMoved[bufnr] = vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.clear_references()
          end,
        })
      end
    end
  end,
})

autocmd("LspDetach", {
  group = augroup("lsp_d"),
  callback = function(args)
    local bufnr = args.buf
    -- vim.api.nvim_del_autocmd(mid) 自动 del
    clientCache(args.data.client_id).CursorHold[bufnr] = nil
    clientCache(args.data.client_id).CursorHoldI[bufnr] = nil
    clientCache(args.data.client_id).CursorMoved[bufnr] = nil
    LSP_COMMAND_CACHE[bufnr] = nil
  end,
})


require("kide.melspconfig").init_lsp_progress()
