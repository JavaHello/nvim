require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local command = vim.api.nvim_create_user_command

map("n", ";", ":", { desc = "CMD enter command mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- dap
map("n", "<leader>db", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Dap toggle breakpoint" })
map("n", "<leader>dB", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Dap toggle breakpoint" })

-- outline
map("n", "<leader>o", "<CMD>SymbolsOutline<CR>", { desc = "Symbols Outline" })

command("CloseOtherBuffer", function()
  require("nvchad.tabufline").closeOtherBufs()
end, { desc = "Closes all bufs except current one" })

map("v", "<leader>fw", function()
  local tb = require "telescope.builtin"
  local text = require("kide.core.utils").get_visual_selection()
  tb.live_grep { default_text = text }
end, { desc = "telescope live grep" })

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
