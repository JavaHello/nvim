local utils = require("kide.core.utils")
local M = {}

local function maven_settings()
  local maven_home = os.getenv("MAVEN_HOME")
  if maven_home then
    return maven_home .. "/conf/settings.xml"
  end
end

M.get_maven_settings = function()
  return os.getenv("MAVEN_SETTINGS") or maven_settings()
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
local function create_command(buf, name, cmd, complete)
  vim.api.nvim_buf_create_user_command(buf, name, function(opts)
    if opts.args then
      exec(cmd .. " " .. opts.args, vim.fn.expand("%"))
    else
      exec(cmd, vim.fn.expand("%"))
    end
  end, {
    nargs = "*",
    complete = complete,
  })
end

local maven_args_complete = utils.command_args_complete

M.maven_command = function(buf)
  create_command(buf, "MavenCompile", "mvn compile", maven_args_complete({ "test-compile" }, { multiple = true }))
  create_command(
    buf,
    "MavenInstll",
    "mvn clean install",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { single = true })
  )
  create_command(
    buf,
    "MavenPackage",
    "mvn clean package",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { single = true })
  )
  create_command(
    buf,
    "MavenDependencyTree",
    "mvn dependency:tree",
    maven_args_complete({ "-Doutput=.dependency.txt" }, { multiple = true })
  )
  create_command(buf, "MavenDependencyAnalyzeDuplicate", "mvn dependency:analyze-duplicate")
  create_command(buf, "MavenDependencyAnalyzeOnly", "mvn dependency:analyze-only -Dverbose")
  create_command(buf, "MavenDownloadSources", "mvn dependency:sources -DdownloadSources=true")
  create_command(buf, "MavenTest", "mvn test", maven_args_complete({ "-Dtest=" }, {}))
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
