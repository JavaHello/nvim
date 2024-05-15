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
    "dap-repl",
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

-- outline
autocmd("FileType", {
  group = augroup "OUTLINE",
  pattern = {
    "OUTLINE",
  },
  callback = function(_)
    vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "signcolumn", "no")
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
autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

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
  callback = function(args)
    local bufnr = args.buf
    -- local client = vim.lsp.get_client_by_id(args.data.client_id)
    if clientCache(args.data.client_id).CursorHold[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorHold[bufnr])
      clientCache(args.data.client_id).CursorHold[bufnr] = nil
    end
    if clientCache(args.data.client_id).CursorHoldI[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorHoldI[bufnr])
      clientCache(args.data.client_id).CursorHoldI[bufnr] = nil
    end
    if clientCache(args.data.client_id).CursorMoved[bufnr] then
      vim.api.nvim_del_autocmd(clientCache(args.data.client_id).CursorMoved[bufnr])
      clientCache(args.data.client_id).CursorMoved[bufnr] = nil
    end
  end,
})

-- jdtls
autocmd({ "BufReadCmd" }, {
  group = augroup "jdtls_open",
  pattern = { "*.class" },
  callback = function(event)
    require("jdtls").open_classfile(event.file)
  end,
})
