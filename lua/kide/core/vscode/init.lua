local M = {}
local env = {
  VSCODE_EXTENSIONS = vim.env["VSCODE_EXTENSIONS"],
}
M.get_vscode_extensions = function()
  return env.VSCODE_EXTENSIONS or "~/.vscode/extensions"
end
M.find_one = function(extension_path)
  local v = vim.fn.glob(M.get_vscode_extensions() .. extension_path)
  if v and v ~= "" then
    if type(v) == "string" then
      local pt = vim.split(v, "\n")
      return pt[#pt]
    elseif type(v) == "table" then
      return v[1]
    end
    return v
  end
end

return M
