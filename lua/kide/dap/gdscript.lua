local M = {}

M.setup = function()
  local dap = require("dap")
  dap.adapters.godot = {
    type = "server",
    host = "127.0.0.1",
    port = 6006,
  }
  dap.configurations.gdscript = {
    {
      type = "godot",
      request = "launch",
      name = "Launch scene",
      project = "${workspaceFolder}",
      launch_scene = true,
    },
  }
end
return M
