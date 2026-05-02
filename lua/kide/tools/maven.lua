local M = {}

local function maven_settings()
  if vim.fn.filereadable(vim.fn.expand("~/.m2/settings.xml")) == 1 then
    return vim.fn.expand("~/.m2/settings.xml")
  end
  local maven_home = vim.env["MAVEN_HOME"]
  if maven_home then
    local settings_xml = vim.fs.joinpath(maven_home, "conf", "settings.xml")
    if vim.fn.filereadable(settings_xml) == 1 then
      return settings_xml
    end
  end
end

M.get_maven_settings = function()
  return vim.env["MAVEN_SETTINGS_XML"] or maven_settings()
end

return M
