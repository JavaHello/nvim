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
  vim.api.nvim_buf_create_user_command(buf, "MavenDownloadSources", function()
    require("toggleterm").exec("mvn dependency:sources -DdownloadSources=true" .. settings_opt(settings))
  end, {
    nargs = 0,
  })
end

M.setup = function()
  local group = vim.api.nvim_create_augroup("kide_jdtls_java_maven", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "xml" },
    desc = "maven_command",
    callback = function(e)
      if vim.endswith(e.file, "pom.xml") then
        M.maven_command(e.buf)
      end
    end,
  })
end
return M
