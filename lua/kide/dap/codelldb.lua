local M = {}
local vscode = require("kide.core.vscode")
local utils = require("kide.core.utils")
-- Update this path
M.extension_path = (function()
  local epath = vscode.find_one("/vadimcn.vscode-lldb-*")
  if epath then
    return epath
  elseif require("mason-registry").has_package("codelldb") then
    return require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension"
  end
end)()
M.codelldb_path = (function()
  if M.extension_path then
    if utils.is_win then
      return vim.fn.glob(M.extension_path .. "/adapter/codelldb.exe")
    else
      return vim.fn.glob(M.extension_path .. "/adapter/codelldb")
    end
  end
end)()
M.liblldb_path = (function()
  if M.extension_path then
    if utils.is_mac then
      return vim.fn.glob(M.extension_path .. "/lldb/lib/liblldb.dylib")
    elseif utils.is_win then
      return vim.fn.glob(M.extension_path .. "/lldb/bin/liblldb.dll")
    else
      return vim.fn.glob(M.extension_path .. "/lldb/lib/liblldb.so")
    end
  end
end)()

M.setup = function()
  if not M.extension_path then
    vim.notify("codelldb not found", vim.log.levels.WARN)
    return false
  end
  local dap = require("dap")
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = M.codelldb_path,
      args = { "--liblldb", M.liblldb_path, "--port", "${port}" },
      -- On windows you may have to uncomment this:
      -- detached = false,
    },
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
  dap.configurations.c = dap.configurations.cpp
  -- dap.configurations.rust = dap.configurations.cpp
  return true
end
return M
