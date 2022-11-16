local M = {}

local function settings_opt(settings)
  if settings then
    return " -s " .. settings
  end
  return ""
end

M.maven_command = function(buf, settings)
  vim.api.nvim_buf_create_user_command(buf, "MavenCompile", function()
    require("toggleterm").exec("mvn compile test-compile" .. settings_opt(settings))
  end, {
    nargs = 0,
  })
  vim.api.nvim_buf_create_user_command(buf, "MavenInstll", function()
    require("toggleterm").exec("mvn clean install" .. settings_opt(settings))
  end, {
    nargs = 0,
  })
  vim.api.nvim_buf_create_user_command(buf, "MavenPpckage", function()
    require("toggleterm").exec("mvn clean package" .. settings_opt(settings))
  end, {
    nargs = 0,
  })
  vim.api.nvim_buf_create_user_command(buf, "MavenDependency", function()
    require("toggleterm").exec("mvn dependency:tree -Doutput=.dependency.txt" .. settings_opt(settings))
  end, {
    nargs = 0,
  })
end
return M
