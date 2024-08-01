local utils = require "kide.core.utils"
local M = {}

local function maven_settings()
  if vim.fn.filereadable(vim.fn.expand "~/.m2/settings.xml") == 1 then
    return vim.fn.expand "~/.m2/settings.xml"
  end
  local maven_home = vim.env["MAVEN_HOME"]
  if maven_home and vim.fn.filereadable(maven_home .. "/conf/settings.xml") then
    return maven_home .. "/conf/settings.xml"
  end
end

M.get_maven_settings = function()
  return vim.env["MAVEN_SETTINGS_XML"] or maven_settings()
end

local function settings_opt(settings)
  if settings then
    return " -s " .. settings
  end
  return ""
end

M.is_pom_file = function(file)
  return vim.endswith(file, "pom.xml")
end

local function pom_file(file)
  if M.is_pom_file(file) then
    return " -f " .. file
  end
  return ""
end

local exec = function(cmd, pom, opt)
  opt = opt or {}

  local ok, overseer = pcall(require, "overseer")
  if ok then
    local task = overseer.new_task {
      cmd = cmd,
    }
    task:start()
  else
    require("nvchad.term").runner {
      pos = "sp",
      cmd = cmd .. settings_opt(M.get_maven_settings()) .. pom_file(pom),
      id = "maven",
      clear_cmd = true,
    }
  end
end
local function create_command(buf, name, cmd, complete, opt)
  vim.api.nvim_buf_create_user_command(buf, name, function(opts)
    if type(cmd) == "function" then
      cmd = cmd(opts)
    end
    if cmd == nil then
      return
    end

    if opts.args then
      exec(cmd .. " " .. opts.args, vim.fn.expand "%", opt)
    else
      exec(cmd, vim.fn.expand "%", opt)
    end
  end, {
    nargs = "*",
    complete = complete,
  })
end

local maven_args_complete = utils.command_args_complete

M.maven_command = function(buf)
  -- 判断为 java 文件
  if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "java" then
    create_command(buf, "MavenExecJava", function(_)
      local filename = vim.fn.expand "%:p"
      filename = string.gsub(filename, "^[%-/%w%s]*%/src%/main%/java%/", "")
      filename = string.gsub(filename, "[/\\]", ".")
      filename = string.gsub(filename, "%.java$", "")
      return 'mvn exec:java -Dexec.mainClass="' .. filename .. '"'
    end, nil, { update = true, close_on_exit = false })
  end
  create_command(
    buf,
    "MavenCompile",
    "mvn clean compile",
    maven_args_complete({ "test-compile" }, { model = "multiple" }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenInstll",
    "mvn clean install",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { model = "single" }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenPackage",
    "mvn clean package",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { model = "single" }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenDependencyTree",
    "mvn dependency:tree",
    maven_args_complete({ "-Doutput=.dependency.txt" }, { model = "single" }),
    { close_on_exit = false }
  )
  create_command(buf, "MavenDependencyAnalyzeDuplicate", "mvn dependency:analyze-duplicate", nil, {
    close_on_exit = false,
  })
  create_command(buf, "MavenDependencyAnalyzeOnly", "mvn dependency:analyze-only -Dverbose", nil, {
    close_on_exit = false,
  })
  create_command(buf, "MavenDownloadSources", "mvn dependency:sources -DdownloadSources=true")
  create_command(
    buf,
    "MavenTest",
    "mvn test",
    maven_args_complete({ "-Dtest=" }, { model = "single" }),
    { close_on_exit = false }
  )
end

M.setup = function()
  local group = vim.api.nvim_create_augroup("kide_jdtls_java_maven", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "xml", "java" },
    desc = "maven_command",
    callback = function(e)
      if vim.endswith(e.file, "pom.xml") or vim.endswith(e.file, ".java") then
        M.maven_command(e.buf)
      end
    end,
  })

  local opt = { update = true, close_on_exit = false }
  vim.api.nvim_create_user_command("Maven", function(opts)
    if opts.args then
      exec("mvn " .. opts.args, vim.fn.expand "%", opt)
    else
      exec("mvn", vim.fn.expand "%", opt)
    end
  end, {
    nargs = "*",
    complete = maven_args_complete({
      "clean",
      "compile",
      "test-compile",
      "verify",
      "package",
      "install",
      "deploy",
    }, { model = "multiple" }),
  })
end
return M
