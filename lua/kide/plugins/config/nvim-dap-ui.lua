local dap = require("dap")
-- dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
-- dap.defaults.fallback.focus_terminal = true
-- dap.defaults.fallback.external_terminal = {
--   command = '/opt/homebrew/bin/alacritty';
--   args = { '-e' };
-- }
local dapui = require("dapui")
dapui.setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  layouts = {
    {
      -- You can change the order of elements in the sidebar
      elements = {
        -- Provide IDs as strings or tables with "id" and "size" keys
        {
          id = "scopes",
          size = 0.25, -- Can be float or integer > 1
        },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.3 },
        { id = "console", size = 0.7 },
      },
      size = 0.25,
      position = "bottom",
    },
  },
})
local M = { dapui_active = false }

local function auto_close(bufnr)
  local acid
  acid = vim.api.nvim_create_autocmd({ "BufDelete", "BufHidden" }, {
    buffer = bufnr,
    callback = function()
      if M.dapui_active then
        require("dapui").close()
        M.dapui_active = false
      else
        dap.repl.close()
      end
      vim.api.nvim_del_autocmd(acid)
    end,
  })
end

-- dap.defaults.fallback.terminal_win_cmd = "belowright 12new | set filetype=dap-terminal"
local dapui_console = dap.defaults.fallback.terminal_win_cmd
dap.defaults.fallback.terminal_win_cmd = function()
  if M.dapui_active then
    local bufnr = dapui_console()
    auto_close(bufnr)
    return bufnr
  else
    local cur_win = vim.api.nvim_get_current_win()
    -- open terminal
    vim.api.nvim_command("belowright 12new")
    local bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].filetype = "dap-terminal"

    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
    auto_close(bufnr)
    return bufnr, win
  end
end

dap.listeners.after.event_initialized["dapui_config"] = function()
  -- dapui.open()
  if not M.dapui_active then
    dap.repl.open()
  end
end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end
-- nvim-dap
vim.api.nvim_create_user_command("DapUIOpen", function()
  M.dapui_active = true
  require("dapui").open()
end, {})
vim.api.nvim_create_user_command("DapUIClose", function()
  M.dapui_active = false
  require("dapui").close()
end, {})
vim.api.nvim_create_user_command("DapUIToggle", function()
  M.dapui_active = not M.dapui_active
  require("dapui").toggle()
end, {})
