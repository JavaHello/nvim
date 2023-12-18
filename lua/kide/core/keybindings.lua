-- vim.g.mapleader = ";"
-- vim.g.maplocalleader = ";"

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }
local keymap = vim.keymap.set
local M = {}

M.setup = function()
  -- Esc
  -- map("i", "jk", "<C-\\><C-N>", opt)
  -- n 模式下复制内容到系统剪切板
  -- map("n", "<Leader>c", '"+yy', opt)
  -- v 模式下复制内容到系统剪切板
  -- map("v", "<Leader>c", '"+yy', opt)
  -- n 模式下粘贴系统剪切板的内容
  -- map("n", "<Leader>v", '"+p', opt)
  -- 取消搜索高亮显示
  map("n", "<Leader><CR>", "<CMD>nohlsearch<CR>", opt)
  map("n", "<Esc>", "<CMD>nohlsearch<CR>", opt)

  keymap("n", "<C-h>", "<C-w>h", opt)
  keymap("n", "<C-j>", "<C-w>j", opt)
  keymap("n", "<C-k>", "<C-w>k", opt)
  keymap("n", "<C-l>", "<C-w>l", opt)

  map("n", "<up>", "<CMD>res +5<CR>", opt)
  map("n", "<down>", "<CMD>res -5<CR>", opt)
  map("n", "<S-up>", "<CMD>res -5<CR>", opt)
  map("n", "<S-down>", "<CMD>res +5<CR>", opt)
  map("n", "<left>", "<CMD>vertical resize+5<CR>", opt)
  map("n", "<right>", "<CMD>vertical resize-5<CR>", opt)
  map("n", "<S-left>", "<CMD>vertical resize-5<CR>", opt)
  map("n", "<S-right>", "<CMD>vertical resize+5<CR>", opt)

  vim.api.nvim_create_user_command("BufferCloseOther", function()
    require("kide.core.utils").close_other_bufline()
  end, {})
  map("n", "<Leader>s", "<CMD>write<CR>", opt)
  map("n", "<Leader>w", "<CMD>bdelete<CR>", opt)
  map("n", "<Leader>W", "<CMD>%bd<CR>", opt)
  map("n", "<Leader>q", "<CMD>q<CR>", opt)
  -- buffer
  map("n", "<leader>n", "<CMD>BufferLineCycleNext <CR>", opt)
  map("n", "<leader>p", "<CMD>BufferLineCyclePrev <CR>", opt)
  -- window
  map("n", "<A-[>", "<CMD>vertical resize +5 <CR>", opt)
  map("n", "<A-]>", "<CMD>vertical resize -5  <CR>", opt)

  -- " 退出 terminal 模式
  map("t", "<Esc>", "<C-\\><C-N>", opt)
  -- map("t", "jk", "<C-\\><C-N>", opt)

  -- ToggleTerm
  map("n", "<F12>", "<CMD>ToggleTerm<CR>", opt)
  map("t", "<F12>", "<C-\\><C-N><CMD>ToggleTerm<CR>", opt)
  map("n", "<leader>tt", "<CMD>ToggleTerm<CR>", opt)
  map("v", "<leader>tt", "<CMD>ToggleTermSendVisualSelection<CR>", opt)
  -- map("t", "tt", "<C-\\><C-N>:ToggleTerm<CR>", opt)

  -- symbols-outline.nvim
  map("n", "<leader>o", "<CMD>SymbolsOutline<CR>", opt)

  -- Telescope
  map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opt)
  keymap("v", "<leader>ff", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.find_files({ default_text = text })
  end, opt)
  map("n", "<C-p>", "<cmd>Telescope find_files<cr>", opt)
  map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opt)
  keymap("v", "<leader>fg", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.live_grep({ default_text = text })
  end, opt)
  map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opt)
  map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opt)

  -- camel_case
  require("kide.core.utils").camel_case_init()

  -- nvim-dap
  keymap("n", "<F5>", "<CMD>lua require'dap'.continue()<CR>", opt)
  keymap("n", "<F6>", "<CMD>lua require'dap'.step_over()<CR>", opt)
  keymap("n", "<F7>", "<CMD>lua require'dap'.step_into()<CR>", opt)
  keymap("n", "<F8>", "<CMD>lua require'dap'.step_out()<CR>", opt)
  keymap("n", "<leader>db", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", opt)
  keymap("n", "<leader>dB", "<CMD>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opt)
  keymap(
    "n",
    "<leader>dp",
    "<CMD>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
    opt
  )
  keymap("n", "<leader>dr", "<CMD>lua require'dap'.repl.open()<CR>", opt)
  keymap("n", "<leader>dl", "<CMD>lua require'dap'.run_last()<CR>", opt)

  -- nvim-dap-ui
  keymap("n", "<leader>ds", ':lua require("dapui").float_element(vim.Nil, { enter = true}) <CR>', opt)

  -- bufferline.nvim
  keymap("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", opt)
  keymap("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", opt)
  keymap("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", opt)
  keymap("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", opt)
  keymap("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", opt)
  keymap("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", opt)
  keymap("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", opt)
  keymap("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", opt)
  keymap("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", opt)

  -- nvim-spectre
  map("n", "<leader>S", "<cmd>lua require('spectre').open()<CR>", opt)
  -- search current word
  map("n", "<leader>fr", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", opt)
  map("v", "<leader>fr", "<esc>:lua require('spectre').open_visual()<CR>", opt)

  -- ToggleTerm
  map("n", "<leader>ft", "<cmd>TermSelect<cr>", opt)
  -- ToggleTask
  map("n", "<leader>ts", "<cmd>Telescope toggletasks spawn<cr>", opt)

  -- nvimTree
  map("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", opt)

  -- set keybinds for both INSERT and VISUAL.
  vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
  vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
  vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
  vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

  -- todo-comments
  vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
  end, { desc = "Next todo comment" })

  vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
  end, { desc = "Previous todo comment" })
end
-- lsp 回调函数快捷键设置
M.maplsp = function(client, buffer, null_ls)
  local bufopts = { noremap = true, silent = true, buffer = buffer }
  vim.api.nvim_buf_set_keymap(buffer, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
  -- rename
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
  -- mapbuf('n', '<leader>rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opt)
  -- code action
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "v", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)
  -- mapbuf('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opt)
  -- diagnostic
  vim.api.nvim_buf_set_keymap(buffer, "n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "]g", "<cmd>lua vim.diagnostic.goto_next()<CR>", opt)
  vim.api.nvim_buf_set_keymap(
    buffer,
    "n",
    "[e",
    "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>",
    opt
  )
  vim.api.nvim_buf_set_keymap(
    buffer,
    "n",
    "]e",
    "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>",
    opt
  )

  keymap("n", "<leader>=", function()
    local bfn = vim.api.nvim_get_current_buf()
    vim.lsp.buf.format({
      bufnr = bfn,
      filter = function(c)
        return require("kide.lsp.utils").filter_format_lsp_client(c, bfn)
      end,
    })
  end, bufopts)
  vim.api.nvim_buf_set_keymap(
    buffer,
    "v",
    "<leader>=",
    '<cmd>lua require("kide.lsp.utils").format_range_operator()<CR>',
    opt
  )

  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>xw", "<cmd>Telescope diagnostics<CR>", opt)
  vim.api.nvim_buf_set_keymap(
    buffer,
    "n",
    "<leader>xe",
    "<cmd>lua require('telescope.builtin').diagnostics({ severity = vim.diagnostic.severity.ERROR })<CR>",
    opt
  )

  -- -------- null_ls 不支持快捷键不绑定 -------------------------------
  if null_ls then
    return
  end
  -- go xx
  -- mapbuf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opt)

  if client.supports_method("textDocument/definition") then
    vim.api.nvim_buf_set_keymap(buffer, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opt)
  else
    vim.api.nvim_buf_set_keymap(buffer, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt)
  end

  vim.api.nvim_buf_set_keymap(buffer, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gi", "<cmd>Telescope lsp_implementations<CR>", opt)
  vim.api.nvim_buf_set_keymap(
    buffer,
    "n",
    "gr",
    "<cmd>lua require('telescope.builtin').lsp_references({jump_type='never'})<CR>",
    opt
  )
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opt)
  keymap("v", "<leader>fs", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.lsp_workspace_symbols({ default_text = text, query = text })
  end, opt)

  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>fo", "<cmd>Telescope lsp_document_symbols<CR>", opt)
  -- >= 0.8.x
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd(string.format("au CursorHold  <buffer=%d> lua vim.lsp.buf.document_highlight()", buffer))
    vim.cmd(string.format("au CursorHoldI <buffer=%d> lua vim.lsp.buf.document_highlight()", buffer))
    vim.cmd(string.format("au CursorMoved <buffer=%d> lua vim.lsp.buf.clear_references()", buffer))
  end
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>cr", "<Cmd>lua vim.lsp.codelens.refresh()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>ce", "<Cmd>lua vim.lsp.codelens.run()<CR>", opt)
end

-- nvim-cmp 自动补全
M.cmp = function(cmp)
  local luasnip = require("luasnip")
  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
      return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
  end
  return {
    -- ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      -- select = true,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      local neogen = require("neogen")
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif neogen.jumpable() then
        neogen.jump_next()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      local neogen = require("neogen")
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif neogen.jumpable(true) then
        neogen.jump_prev()
      else
        fallback()
      end
    end, { "i", "s" }),
  }
end

M.ufo_mapkey = function()
  -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
  vim.keymap.set("n", "zR", require("ufo").openAllFolds)
  vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
end

return M
