-- add yours here

local map = vim.keymap.set
local command = vim.api.nvim_create_user_command

-- map("n", "<leader>gb", require("gitsigns").blame_line, { desc = "gitsigns blame line" })

map("n", "<up>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<down>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-up>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-down>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<left>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })
map("n", "<right>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-left>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-right>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })

map("n", "==", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "format file" })

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

map("v", "<leader>fm", function()
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

-- jdtls
command("JdtWipeDataAndRestart", function()
  require("jdtls.setup").wipe_data_and_restart()
end, { desc = "Jdt Wipe Data And Restart" })
command("JdtShowLogs", function()
  require("jdtls.setup").show_logs()
end, { desc = "Jdt Show Logs" })

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

if vim.fn.executable("fzy") == 1 then
  map("n", "<leader>ff", function()
    local fzy = require("kide.fzy")
    fzy.execute("fd --type file", fzy.sinks.edit_file, "  ")
  end, { desc = "Find files" })

  map("v", "<leader>ff", function()
    vim.api.nvim_feedkeys("\027", "xt", false)
    local text = require("kide.tools").get_visual_selection()
    local fzy = require("kide.fzy")
    local param = vim.fn.shellescape(text[1])
    fzy.execute("fd --type file " .. param, fzy.sinks.edit_file, "  ")
  end, { desc = "fzy find files", silent = true, noremap = true })

  map("v", "<leader>fw", function()
    vim.api.nvim_feedkeys("\027", "xt", false)
    local text = require("kide.tools").get_visual_selection()
    local fzy = require("kide.fzy")
    local param = vim.fn.shellescape(text[1])
    fzy.execute("rg --vimgrep --no-heading --smart-case " .. param, fzy.sinks.edit_live_grep, "  ")
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
    require("kide.tools.ai").translate_float({ text = text, from = from, to = to })
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
