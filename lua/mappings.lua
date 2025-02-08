-- add yours here

local map = vim.keymap.set
local command = vim.api.nvim_create_user_command

map("n", "<A-i>", function()
  require("kide.term").toggle()
  vim.cmd("startinsert")
end, { desc = "toggle term" })
map("t", "<A-i>", require("kide.term").toggle, { desc = "toggle term" })
map("i", "<A-i>", function()
  vim.cmd("stopinsert")
  require("kide.term").toggle()
end, { desc = "toggle term" })
map("v", "<A-i>", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  require("kide.term").toggle()
  vim.defer_fn(function()
    require("kide.term").send_line(text[1])
  end, 500)
end, { desc = "toggle term" })


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
map("n", "<F5>", function()
  require("dap").continue()
end, {
  desc = "Dap continue",
})
map("n", "<F10>", function()
  require("dap").step_over()
end, {
  desc = "Dap step_over",
})
map("n", "<F11>", function()
  require("dap").step_into()
end, {
  desc = "Dap step_into",
})
map("n", "<F12>", function()
  require("dap").step_out()
end, {
  desc = "Dap step_out",
})
map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Dap toggle breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Dap breakpoint condition" })
map("n", "<leader>dl", function()
  require("dap").run_last()
end, {
  desc = "Dap run last",
})
map("n", "<Leader>lp", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, {
  desc = "Dap set_breakpoint",
})
map("n", "<Leader>dr", function()
  require("dap").repl.open()
end, {
  desc = "Dap repl open",
})
map({ "n", "v" }, "<Leader>dh", function()
  require("dap.ui.widgets").hover()
end, {
  desc = "Dap hover",
})
map({ "n", "v" }, "<Leader>dp", function()
  require("dap.ui.widgets").preview()
end, {
  desc = "Dap preview",
})
map("n", "<Leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, {
  desc = "Dap centered_float frames",
})
map("n", "<Leader>dv", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, {
  desc = "Dap centered_float scopes",
})

map("n", "<leader>e", function()
  Snacks.explorer.open({})
end, { desc = "files", silent = true, noremap = true })

-- outline
map("n", "<leader>o", "<CMD>Outline<CR>", { desc = "Symbols Outline" })

-- task
command("TaskRun", function()
  require("kide.term").input_run(false)
end, { desc = "Task Run" })

command("TaskRunLast", function()
  require("kide.term").input_run(true)
end, { desc = "Restart Last Task" })

map("n", "<A-l>", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "format file" })
map("v", "<A-l>", function()
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
command("CloseOtherBufs", function(_)
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

map("n", "<leader>fq", function()
  Snacks.picker.qflist()
end, { desc = "Quickfix" })

map("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "Find buffer" })
map("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "Find files" })

map("n", "<leader>fd", function()
  Snacks.picker.diagnostics()
end, { desc = "Find diagnostics" })

map("v", "<leader>ff", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  local param = text[1]
  Snacks.picker.files({ args = { param } })
end, { desc = "find files", silent = true, noremap = true })

map("v", "<leader>fw", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  local param = text[1]
  Snacks.picker.grep({ search = param })
end, { desc = "live grep", silent = true, noremap = true })
map("n", "<leader>fw", function()
  Snacks.picker.grep()
end, { desc = "live grep", silent = true, noremap = true })

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
  local q
  local code
  if opt.range > 0 then
    code = require("kide.tools").get_visual_selection()
  end
  if opt.args and opt.args ~= "" then
    q = opt.args
  end
  require("kide.gpt.chat").toggle_gpt({
    code = code,
    question = q,
  })
end, {
  desc = "Gpt",
  nargs = "*",
  range = true,
})
map("n", "<A-k>", require("kide.gpt.chat").toggle_gpt, { desc = "Gpt" })
map("i", "<A-k>", require("kide.gpt.chat").toggle_gpt, { desc = "Gpt" })
map("v", "<A-k>", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.tools").get_visual_selection()
  require("kide.gpt.chat").toggle_gpt({
    code = text,
  })
end, { desc = "Gpt" })
command("GptLast", function(opt)
  require("kide.gpt.chat").toggle_gpt({
    last = true,
  })
end, {
  desc = "Gpt",
  nargs = "*",
  range = true,
})

command("GptReasoner", function()
  require("kide.gpt.reasoner").toggle_gpt()
end, {
  desc = "GptReasoner",
  nargs = "*",
  range = true,
})

command("LspInfo", function(_)
  require("kide.lspui").open_info()
end, {
  desc = "Lsp info",
  nargs = 0,
  range = false,
})
command("LspLog", function(_)
  vim.cmd("tabedit " .. vim.lsp.log.get_filename())
  vim.cmd("normal! G")
end, {
  desc = "Lsp log",
  nargs = 0,
  range = false,
})

require("kide.tools").setup()
require("kide.tools.maven").setup()
require("kide.tools.plantuml").setup()
require("kide.tools.curl").setup()
require("kide.gpt.commit").setup()
