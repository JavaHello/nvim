require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local command = vim.api.nvim_create_user_command

map("n", ";", ":", { desc = "CMD enter command mode" })

-- <C-I> 按键映射问题
vim.keymap.del("n", "<tab>")
vim.keymap.del("n", "<S-tab>")
-- map("n", "<leader>n", function()
--   require("nvchad.tabufline").next()
-- end, { desc = "buffer goto next" })
--
-- map("n", "<leader>p", function()
--   require("nvchad.tabufline").prev()
-- end, { desc = "buffer goto prev" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- vim.keymap.del("n", "<leader>x")
-- map("n", "<leader>x", "<CMD>bd<CR>", { desc = "Close buffer" })

-- vim.keymap.del("n", "<leader>n")
-- vim.keymap.del("n", "<leader>p")
map("n", "<leader>n", "<CMD>bn<CR>", { desc = "buffer goto next" })
map("n", "<leader>p", "<CMD>bp<CR>", { desc = "buffer goto prev" })

map("n", "<up>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<down>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-up>", "<CMD>res -5<CR>", { desc = "Resize -5" })
map("n", "<S-down>", "<CMD>res +5<CR>", { desc = "Resize +5" })
map("n", "<left>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })
map("n", "<right>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-left>", "<CMD>vertical resize-5<CR>", { desc = "Vertical Resize -5" })
map("n", "<S-right>", "<CMD>vertical resize+5<CR>", { desc = "Vertical Resize +5" })

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

-- outline
map("n", "<leader>o", "<CMD>Outline<CR>", { desc = "Symbols Outline" })

-- task
command("TaskToggle", function()
  require("overseer").toggle {}
end, { desc = "Task" })

command("TaskRun", function()
  require("overseer").run_template {}
end, { desc = "Task Run" })

command("TaskRunLast", function()
  local overseer = require "overseer"
  local tasks = overseer.list_tasks { recent_first = true }
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end, { desc = "Restart Last Task" })

command("CloseOtherBuffer", function()
  require("nvchad.tabufline").closeAllBufs(false)
end, { desc = "Closes all bufs except current one" })
-- command("CloseAllBuffer", function()
--   require("nvchad.tabufline").closeAllBufs(true)
-- end, { desc = "Closes all bufs" })

-- Telescope
map("v", "<leader>ff", function()
  -- vim.fn.getpos 获取最新光标位置
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.core.utils").get_visual_selection()
  local tb = require "telescope.builtin"
  tb.find_files { default_text = text }
end, { desc = "telescope find files", silent = true, noremap = true })
map("v", "<leader>fw", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.core.utils").get_visual_selection()
  local tb = require "telescope.builtin"
  tb.live_grep { default_text = text }
end, { desc = "telescope live grep", silent = true, noremap = true })

map("v", "<leader>fm", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  require("conform").format {
    range = {
      start = start_pos,
      ["end"] = end_pos,
    },
    lsp_fallback = true,
  }
end, { desc = "format range", silent = true, noremap = true })

-- Git
map("n", "]c", function()
  local gs = require "gitsigns"
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    gs.next_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git Next Hunk" })

map("n", "[c", function()
  local gs = require "gitsigns"
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    gs.prev_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git Prev Hunk" })

-- LSP
map("n", "]d", function()
  -- vim.diagnostic.jump { count = 1 }
  vim.diagnostic.goto_next()
end, { desc = "Jump to the next diagnostic" })
map("n", "[d", function()
  -- vim.diagnostic.jump { count = -1 }
  vim.diagnostic.goto_prev()
end, { desc = "Jump to the previous diagnostic" })

map("n", "[e", function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end, { desc = "Jump to the previous diagnostic error" })
map("n", "]e", function()
  vim.diagnostic.goto_next { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = "Jump to the next diagnostic error" })
map("n", "gs", vim.lsp.buf.signature_help, { desc = "lsp signature help" })
map("n", "go", vim.diagnostic.open_float, { desc = "lsp signature help" })

command("InlayHint", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
end, { desc = "LSP Inlay Hint" })
command("CodeLens", function()
  vim.lsp.codelens.refresh()
end, { desc = "LSP CodeLens" })
command("CodeLensClear", function()
  vim.lsp.codelens.clear()
end, { desc = "LSP CodeLens" })

-- map("v", "<leader>fs", function()
--   vim.api.nvim_feedkeys("\027", "xt", false)
--   local text = require("kide.core.utils").get_visual_selection()
--   require("fzf-lua").lsp_live_workspace_symbols { default_text = text, query = text }
-- end, { desc = "Lsp Workspace Symbols", silent = true, noremap = true })
--
-- map("n", "<leader>fs", function()
--   require("fzf-lua").lsp_live_workspace_symbols {}
-- end, { desc = "Lsp Workspace Symbols" })

local function _on_list()
  local templist = {}
  local tempctx = {}
  return function(ctx)
    vim.list_extend(templist, ctx.items)
    tempctx = vim.tbl_extend("keep", tempctx, ctx)
    tempctx.items = templist
    vim.fn.setqflist({}, " ", tempctx)
    vim.cmd "botright copen"
  end
end

command("DocumentSymbols", function(_)
  vim.lsp.buf.document_symbol {
    on_list = _on_list(),
  }
end, {
  desc = "Lsp Document Symbols",
  nargs = 0,
  range = true,
})

command("WorkspaceSymbols", function(opts)
  if opts.range > 0 then
    local text = require("kide.core.utils").get_visual_selection()
    vim.lsp.buf.workspace_symbol(text, { on_list = _on_list() })
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
    vim.diagnostic.setqflist { severity = level }
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
    vim.diagnostic.setloclist { severity = level }
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
