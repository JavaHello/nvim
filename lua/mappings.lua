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
map("n", "<leader>o", "<CMD>SymbolsOutline<CR>", { desc = "Symbols Outline" })

command("CloseOtherBuffer", function()
  require("nvchad.tabufline").closeOtherBufs()
end, { desc = "Closes all bufs except current one" })

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
map("n", "[e", function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end, { desc = "lsp prev diagnostic error" })
map("n", "]e", function()
  vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
end, { desc = "lsp next diagnostic error" })

map("v", "<leader>fs", function()
  vim.api.nvim_feedkeys("\027", "xt", false)
  local text = require("kide.core.utils").get_visual_selection()
  require("fzf-lua").lsp_live_workspace_symbols { default_text = text, query = text }
end, { desc = "Lsp Workspace Symbols", silent = true, noremap = true })

map("n", "<leader>fs", function()
  require("fzf-lua").lsp_live_workspace_symbols {}
end, { desc = "Lsp Workspace Symbols" })

command("WorkspaceSymbols", function(opts)
  if opts.range > 0 then
    local text = require("kide.core.utils").get_visual_selection()
    vim.lsp.buf.workspace_symbol(text)
  else
    vim.lsp.buf.workspace_symbol(opts.args)
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
