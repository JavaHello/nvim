vim.api.nvim_create_user_command("CodelldbLoad", function()
  if not vim.g.codelldb_load then
    vim.g.codelldb_load = require("kide.dap.codelldb").setup()
  end
end, {})

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
-- vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
-- vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "", linehl = "", numhl = "" })
-- vim.fn.sign_define('DapBreakpointRejected', {text='R', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapLogPoint', {text='L', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapStopped', {text='→', texthl='', linehl='debugPC', numhl=''})
