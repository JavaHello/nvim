local M = {}

local maven_settings = os.getenv("MAVEN_HOME") .. "/conf/settings.xml"
M.get_maven_settings = function()
  return os.getenv("MAVEN_SETTINGS") or maven_settings
end

local function settings_opt(settings)
  if settings then
    return " -s " .. settings
  end
  return ""
end

local function pom_file(file)
  if file and vim.endswith(file, "pom.xml") then
    return " -f " .. file
  end
  return ""
end

local exec = function(cmd, pom)
  require("toggleterm").exec(cmd .. settings_opt(M.get_maven_settings()) .. pom_file(pom))
end
local function create_command(buf, name, cmd)
  vim.api.nvim_buf_create_user_command(buf, name, function()
    exec(cmd, vim.fn.expand("%"))
  end, {
    nargs = 0,
  })
end

M.maven_command = function(buf)
  create_command(buf, "MavenCompile", "mvn compile test-compile")
  create_command(buf, "MavenInstll", "mvn clean install")
  create_command(buf, "MavenPpckage", "mvn clean package")
  create_command(buf, "MavenDependencyTree", "mvn dependency:tree -Doutput=.dependency.txt")
  create_command(buf, "MavenDependencyAnalyzeDuplicate", "mvn dependency:analyze-duplicate")
  create_command(buf, "MavenDependencyAnalyzeOnly", "mvn dependency:analyze-only -Dverbose")
  create_command(buf, "MavenDownloadSources", "mvn dependency:sources -DdownloadSources=true")
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
