-- add yours here

local map = vim.keymap.set
local command = vim.api.nvim_create_user_command

map("n", "<A-i>", require("kide.term").toggle, { desc = "toggle term" })
map("t", "<A-i>", require("kide.term").toggle, { desc = "toggle term" })
map("i", "<A-i>", function()
  vim.cmd("stopinsert")
  require("kide.term").toggle()
end, { desc = "toggle term" })
map("v", "<A-i>", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  require("kide.term").toggle()
  require("kide.term").send_line(text[1])
end, { desc = "toggle term" })

map("n", "<leader>w", function()
  vim.print("---close--")
  vim.print(vim.bo.bufhidden)
  vim.print(vim.bo.buflisted)
end, { desc = "close buf" })

map("n", "<leader>gb", require("gitsigns").blame_line, { desc = "gitsigns blame line" })
map("n", "<ESC>", "<CMD>noh<CR>", { desc = "Clear Highlight" })

map("n", "<up>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<down>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-up>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-down>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<left>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })
map("n", "<right>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-left>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-right>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })
-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- dap
map("n", "<leader>db", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Dap toggle breakpoint" })
map(
  "n",
  "<leader>dB",
  "<CMD>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { desc = "Dap breakpoint condition" }
)
map("n", "<leader>dp", "<CMD>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", {
  desc = "Dap Log point message",
})
map("n", "<leader>dl", "<CMD>lua require'dap'.run_last()<CR>", {
  desc = "Dap run last",
})

map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "files", silent = true, noremap = true })

-- outline
map("n", "<leader>o", "<CMD>Outline<CR>", { desc = "Symbols Outline" })

-- task
command("TaskRun", function()
  require("kide.term").input_run(false)
end, { desc = "Task Run" })

command("TaskRunLast", function()
  require("kide.term").input_run(true)
end, { desc = "Restart Last Task" })

map("n", "<C-l>", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "format file" })
map("v", "<C-l>", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  require("conform").format({
    range = {
      start = start_pos,
      ["end"] = end_pos,
    },
    lsp_fallback = true,
  })
end, { desc = "format range", silent = true, noremap = true })

-- Git
map("n", "]c", function()
  local gs = require("gitsigns")
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    gs.next_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git Next Hunk" })

map("n", "[c", function()
  local gs = require("gitsigns")
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    gs.prev_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git Prev Hunk" })

map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Jump to the previous diagnostic error" })
map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Jump to the next diagnostic error" })
map("n", "go", vim.diagnostic.open_float, { desc = "Open float Diagnostics" })

-- quickfix next/prev
-- map("n", "]q", "<CMD>cnext<CR>", { desc = "Quickfix Next" })
-- map("n", "[q", "<CMD>cprev<CR>", { desc = "Quickfix Prev" })

-- local list next/prev
-- map("n", "]l", "<CMD>lnext<CR>", { desc = "Location List Next" })
-- map("n", "[l", "<CMD>lprev<CR>", { desc = "Location List Prev" })

command("InlayHint", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
end, { desc = "LSP Inlay Hint" })
command("CodeLens", function()
  vim.lsp.codelens.refresh()
end, { desc = "LSP CodeLens" })
command("CodeLensClear", function()
  vim.lsp.codelens.clear()
end, { desc = "LSP CodeLens" })

local function _on_list()
  local templist = {}
  local tempctx = {}
  return function(ctx)
    vim.list_extend(templist, ctx.items)
    tempctx = vim.tbl_extend("keep", tempctx, ctx)
    tempctx.items = templist
    vim.fn.setqflist({}, " ", tempctx)
    vim.cmd("botright copen")
  end
end

command("LspDocumentSymbols", function(_)
  vim.lsp.buf.document_symbol({
    on_list = _on_list(),
  })
end, {
  desc = "Lsp Document Symbols",
  nargs = 0,
  range = true,
})

command("LspWorkspaceSymbols", function(opts)
  if opts.range > 0 then
    local text = require("kide.tools").get_visual_selection()
    vim.lsp.buf.workspace_symbol(text[1], { on_list = _on_list() })
  else
    vim.lsp.buf.workspace_symbol(opts.args, { on_list = _on_list() })
  end
end, {
  desc = "Lsp Workspace Symbols",
  nargs = "?",
  range = true,
})

local severity_key = {
  "ERROR",
  "WARN",
  "INFO",
  "HINT",
}
command("DiagnosticsWorkspace", function(opts)
  local level = opts.args
  if level == nil or level == "" then
    vim.diagnostic.setqflist()
  else
    vim.diagnostic.setqflist({ severity = level })
  end
end, {
  desc = "Diagnostics Workspace",
  nargs = "?",
  complete = function(al, _, _)
    return vim.tbl_filter(function(item)
      return vim.startswith(item, al)
    end, severity_key)
  end,
})
command("DiagnosticsDocument", function(opts)
  local level = opts.args
  if level == nil or level == "" then
    vim.diagnostic.setloclist()
  else
    vim.diagnostic.setloclist({ severity = level })
  end
end, {
  desc = "Diagnostics Document",
  nargs = "?",
  complete = function(al, _, _)
    return vim.tbl_filter(function(item)
      return vim.startswith(item, al)
    end, severity_key)
  end,
})

command("Bn", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })
command("Bp", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

-- find files
if vim.fn.executable("fd") == 1 then
  command("Fd", function(opt)
    vim.fn.setqflist({}, " ", { lines = vim.fn.systemlist("fd --type file " .. opt.args), efm = "%f" })
    vim.cmd("botright copen")
  end, {
    desc = "find files",
    nargs = "?",
  })
end
if vim.fn.executable("find") == 1 then
  command("Find", function(opt)
    vim.fn.setqflist({}, " ", { lines = vim.fn.systemlist("find . -type f -iname '" .. opt.args .. "'"), efm = "%f" })
    vim.cmd("botright copen")
  end, {
    desc = "find files",
    nargs = 1,
  })
end
command("CloseOtherBufs", function(opt)
  local bufs = vim.api.nvim_list_bufs()
  local cur = vim.api.nvim_get_current_buf()
  for _, v in ipairs(bufs) do
    if vim.bo[v].buflisted and cur ~= v then
      local ok = pcall(vim.api.nvim_buf_delete, v, { force = false, unload = false })
      if not ok then
        vim.cmd("b " .. v)
        return
      end
    end
  end
end, {
  desc = "find files",
  nargs = 0,
})

if vim.fn.executable("fzy") == 1 then
  command("Rg", function(opt)
    local fzy = require("kide.fzy")
    fzy.execute("rg --no-heading --trim -nH --smart-case " .. opt.args, fzy.sinks.edit_live_grep, "Grep  ", opt.args)
  end, {
    desc = "Grep",
    nargs = 1,
  })

  map("n", "<leader>fq", function()
    local fzy = require("kide.fzy")
    local qfl = vim.fn.getqflist()
    local tools = require("kide")

    fzy.pick_one(qfl, "Quickfix > ", function(item)
      local filename = vim.uri_from_bufnr(item.bufnr)
      return tools.format_uri(filename) .. ": " .. item.text
    end, function(qf, _)
      if qf then
        vim.cmd("b " .. qf.bufnr)
        vim.api.nvim_win_set_cursor(0, { qf.lnum, qf.col })
      end
    end)
  end, { desc = "Quickfix" })

  map("n", "<leader>fo", function()
    local fzy = require("kide.fzy")
    fzy.execute("fd", function(choice)
      if choice and vim.trim(choice) ~= "" then
        vim.print(choice)
        require("kide.tools").open_fn(choice)
      end
    end, "SystemOpen > ")
  end, { desc = "System Open" })

  map("n", "<leader>fb", function()
    local fzy = require("kide.fzy")
    local bufs = vim.tbl_filter(function(b)
      return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local tools = require("kide")
    fzy.pick_one(bufs, "Buffers > ", function(item)
      if item then
        local filename = vim.uri_from_bufnr(item)
        return tools.format_uri(filename)
      end
    end, function(b, _)
      if b then
        vim.cmd("b " .. b)
      end
    end)
  end, { desc = "Find buffer" })
  map("n", "<leader>ff", function()
    local fzy = require("kide.fzy")
    fzy.execute("fd --type file", fzy.sinks.edit_file, "Files  ")
  end, { desc = "Find files" })

  map("v", "<leader>ff", function()
    vim.api.nvim_feedkeys("\027", "xt", false)
    local text = require("kide.tools").get_visual_selection()
    local fzy = require("kide.fzy")
    local param = vim.fn.shellescape(text[1])
    fzy.execute("fd --type file " .. param, fzy.sinks.edit_file, "Files  ", text[1])
  end, { desc = "fzy find files", silent = true, noremap = true })

  map("v", "<leader>fw", function()
    vim.api.nvim_feedkeys("\027", "xt", false)
    local text = require("kide.tools").get_visual_selection()
    local fzy = require("kide.fzy")
    local param = vim.fn.shellescape(text[1])
    fzy.execute("rg --no-heading --trim -nH --smart-case " .. param, fzy.sinks.edit_live_grep, "Grep  ", text[1])
  end, { desc = "fzy live grep", silent = true, noremap = true })
  map("n", "<leader>fw", function()
    local ok, text = pcall(vim.fn.input, "rg: ")
    if ok and text and text ~= "" then
      local fzy = require("kide.fzy")
      local param = vim.fn.shellescape(text)
      fzy.execute("rg --no-heading --trim -nH --smart-case " .. param, fzy.sinks.edit_live_grep, "Grep  ", text)
    end
  end, { desc = "fzy live grep", silent = true, noremap = true })

  command("FzyFiles", function(opt)
    local fzy = require("kide.fzy")
    local param = vim.fn.shellescape(opt.args)
    fzy.execute("fd --type file " .. param, fzy.sinks.edit_file, "  ")
  end, {
    desc = "find files",
    nargs = "?",
  })
end

if vim.base64 then
  command("Base64Encode", function(opt)
    local text
    if opt.range > 0 then
      text = require("kide.tools").get_visual_selection()
      text = table.concat(text, "\n")
    else
      text = opt.args
    end
    vim.notify(vim.base64.encode(text), vim.log.levels.INFO)
  end, {
    desc = "base64 encode",
    nargs = "?",
    range = true,
  })
  command("Base64Decode", function(opt)
    local text
    if opt.range > 0 then
      text = require("kide.tools").get_visual_selection()
      text = table.concat(text, "\n")
    else
      text = opt.args
    end
    text = require("kide.tools").base64_url_safe_to_std(text)
    vim.notify(vim.base64.decode(text), vim.log.levels.INFO)
  end, {
    desc = "base64 decode",
    nargs = "?",
    range = true,
  })
end

local function creat_trans_command(name, from, to)
  command(name, function(opt)
    local text
    if opt.range > 0 then
      text = require("kide.tools").get_visual_selection()
      text = table.concat(text, "\n")
    else
      text = opt.args
    end
    require("kide.gpt.translate").translate_float({ text = text, from = from, to = to })
  end, {
    desc = "translate",
    nargs = "?",
    range = true,
  })
end

creat_trans_command("TransAutoZh", "auto", "中文")
creat_trans_command("TransEnZh", "英语", "中文")
creat_trans_command("TransZhEn", "中文", "英语")
creat_trans_command("TransIdZh", "印尼语", "中文")

command("Gpt", function(opt)
  local text = nil
  if opt.range > 0 then
    text = require("kide.tools").get_visual_selection()
  end
  require("kide.tools.ai").toggle_gpt(text)
end, {
  desc = "Gpt",
  nargs = 0,
  range = true,
})
map("n", "<A-k>", require("kide.gpt.chat").toggle_gpt, { desc = "Gpt" })
map("i", "<A-k>", require("kide.gpt.chat").toggle_gpt, { desc = "Gpt" })
map("v", "<A-k>", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  require("kide.gpt.chat").toggle_gpt(text)
end, { desc = "Gpt" })

command("LspInfo", function(_)
  require("kide.lspui").open_info()
end, {
  desc = "Gpt",
  nargs = 0,
  range = false,
})
command("LspLog", function(_)
  vim.cmd("tabedit " .. vim.lsp.log.get_filename())
  vim.cmd("normal! G")
end, {
  desc = "Gpt",
  nargs = 0,
  range = false,
})
