local M = {}
local utils = require("kide.core.utils")
local pipe = (function()
  if utils.is_win then
    return vim.env["TEMP"] .. "\\godot.pipe"
  else
    return "/tmp/godot.pipe"
  end
end)()
M.setup = function()
  -- serverstart([{address}])
  -- godot param: --server /tmp/godot.pipe --remote-send "<esc>:n {file}<CR>:call cursor({line},{col})<CR>"
  vim.api.nvim_create_user_command("GododNvimServerStart", function()
    print("start: " .. pipe)
    vim.fn.serverstart(pipe)
  end, {})
  vim.api.nvim_create_user_command("GododNvimServerStop", function()
    vim.fn.serverstop(pipe)
  end, {})
end
return M
