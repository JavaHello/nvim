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
        { id = "repl", size = 1 },
        -- { id = "console", size = 0.5 },
      },
      size = 0.25,
      position = "bottom",
    },
  },
})

dap.defaults.fallback.terminal_win_cmd = "belowright 12new | set filetype=dap-terminal"

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
-- nvim-dap
vim.api.nvim_create_user_command("DapUIOpen", function()
  require("dapui").open({})
end, {})
vim.api.nvim_create_user_command("DapUIClose", function()
  require("dapui").close({})
end, {})
vim.api.nvim_create_user_command("DapUIToggle", function()
  require("dapui").toggle({})
end, {})
