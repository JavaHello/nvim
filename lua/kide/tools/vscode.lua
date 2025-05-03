local M = {}
local env = {
  VSCODE_EXTENSIONS = vim.env["VSCODE_EXTENSIONS"],
  LOMBOK_ENABLE = vim.env["LOMBOK_ENABLE"] or "Y",
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

local mason, _ = pcall(require, "mason-registry")
M.get_lombok_jar = function()
  local lombok_jar = nil
  if env.LOMBOK_ENABLE == "Y" then
    lombok_jar = M.find_one("/redhat.java-*/lombok/lombok-*.jar")
    if lombok_jar == nil and mason and require("mason-registry").has_package("jdtls") then
      lombok_jar = require("mason-registry").get_package("jdtls"):get_install_path() .. "/lombok.jar"
    end
  end
  return lombok_jar
end

return M
