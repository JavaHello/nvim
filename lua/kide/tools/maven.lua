local utils = require("kide.tools")
local M = {
  mvn = vim.fn.exepath("mvn"),
}

local function maven_settings()
  if vim.fn.filereadable(vim.fn.expand("~/.m2/settings.xml")) == 1 then
    return vim.fn.expand("~/.m2/settings.xml")
  end
  local maven_home = vim.env["MAVEN_HOME"]
  if maven_home and vim.fn.filereadable(maven_home .. "/conf/settings.xml") then
    return maven_home .. "/conf/settings.xml"
  end
end

M.get_maven_settings = function()
  return vim.env["MAVEN_SETTINGS_XML"] or maven_settings()
end

M.is_pom_file = function(file)
  return vim.endswith(file, "pom.xml")
end

local exec = function(cmd, args)
  local opt = vim.tbl_deep_extend("force", cmd, {})
  local s = M.get_maven_settings()
  if s then
    table.insert(opt, "-s")
    table.insert(opt, s)
  end
  local p = vim.fn.expand("%")
  if M.is_pom_file(p) then
    table.insert(opt, "-f")
    table.insert(opt, p)
  end
  if args and vim.trim(args) ~= "" then
    vim.list_extend(opt, vim.split(args, " "))
  end
  require("kide.term").toggle(opt)
end
local function create_command(buf, name, cmd, complete)
  vim.api.nvim_buf_create_user_command(buf, name, function(opts)
    if type(cmd) == "function" then
      cmd = cmd(opts)
    end
    if cmd == nil then
      return
    end
    exec(cmd, opts.args)
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
      local filename = vim.fn.expand("%:p")
      filename = string.gsub(filename, "^[%-/%w%s]*%/src%/main%/java%/", "")
      filename = string.gsub(filename, "[/\\]", ".")
      filename = string.gsub(filename, "%.java$", "")
      return { "mvn", 'exec:java -Dexec.mainClass="' .. filename .. '"' }
    end, nil)
  end
  create_command(
    buf,
    "MavenCompile",
    { "mvn", "clean", "compile" },
    maven_args_complete({ "test-compile" }, { model = "multiple" })
  )
  create_command(
    buf,
    "MavenInstall",
    { "mvn", "clean", "install" },
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { model = "single" })
  )
  create_command(
    buf,
    "MavenPackage",
    { "mvn", "clean", "package" },
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { model = "single" })
  )
  create_command(
    buf,
    "MavenDependencyTree",
    { "mvn", "dependency:tree" },
    maven_args_complete({ "-Doutput=.dependency.txt" }, { model = "single" })
  )
  create_command(buf, "MavenDependencyAnalyzeDuplicate", { "mvn", "dependency:analyze-duplicate" }, nil)
  create_command(buf, "MavenDependencyAnalyzeOnly", { "mvn", "dependency:analyze-only", "-Dverbose" }, nil)
  create_command(buf, "MavenDownloadSources", { "mvn", "dependency:sources", "-DdownloadSources=true" })
  create_command(buf, "MavenTest", { "mvn", "test" }, maven_args_complete({ "-Dtest=" }, { model = "single" }))
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

  vim.api.nvim_create_user_command("Maven", function(opts)
    exec({ "mvn" }, opts.args)
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
