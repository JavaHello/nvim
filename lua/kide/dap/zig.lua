local M = {}
M.setup = function()
  local dap = require("dap")
  dap.configurations.zig = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.glob(vim.fn.getcwd() .. "/zig-out/bin/"), "file")
      end,
      args = { "zig" },
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
  return true
end
return M
