local dap = require("dap")
-- dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
-- dap.defaults.fallback.focus_terminal = true
-- dap.defaults.fallback.external_terminal = {
--   command = '/opt/homebrew/bin/alacritty';
--   args = { '-e' };
-- }
local dapui = require("dapui")
dapui.setup({
	layouts = {
		{
			elements = {
				"scopes",
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				"repl",
				-- 'console',
			},
			size = 12,
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

-- vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
-- vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "", linehl = "", numhl = "" })
-- vim.fn.sign_define('DapBreakpointRejected', {text='R', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapLogPoint', {text='L', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapStopped', {text='→', texthl='', linehl='debugPC', numhl=''})

require("nvim-dap-virtual-text").setup()
