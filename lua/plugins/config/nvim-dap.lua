local dap = require('dap')
-- dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
-- dap.defaults.fallback.focus_terminal = true
-- dap.defaults.fallback.external_terminal = {
--   command = '/opt/homebrew/bin/alacritty';
--   args = { '-e' };
-- }

local dapui = require("dapui")
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
  },
  expand_lines = true,
  sidebar = {
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      {
        id = "scopes",
        size = 0.25, -- Can be float or integer > 1
      },
      { id = "breakpoints", size = 0.25 },
      { id = "stacks", size = 0.25 },
      { id = "watches", size = 0.25 },
    },
    size = 40,
    position = "left", -- Can be "left", "right", "top", "bottom"
  },
  tray = {
    elements = { "repl" },
    size = 12,
    position = "bottom", -- Can be "left", "right", "top", "bottom"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  }
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'Debug', linehl = '', numhl = '' })
-- vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "", linehl = "", numhl = "" })
-- vim.fn.sign_define('DapBreakpointRejected', {text='R', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapLogPoint', {text='L', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapStopped', {text='→', texthl='', linehl='debugPC', numhl=''})

require("nvim-dap-virtual-text").setup()
