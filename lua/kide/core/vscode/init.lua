local M = {}
local env = {
  HOME = vim.loop.os_homedir(),
  VSCODE_EXTENSIONS = os.getenv("VSCODE_EXTENSIONS"),
}
M.get_vscode_extensions = function()
  return env.VSCODE_EXTENSIONS or "~/.vscode/extensions"
end
M.find_one = function(extension_path)
  local v = vim.fn.glob(M.get_vscode_extensions() .. extension_path)
  if v and v ~= "" then
    if type(v) == "string" then
      return vim.split(v, "\n")[1]
    elseif type(v) == "table" then
      return v[1]
    end
    return v
  end
end

return M
