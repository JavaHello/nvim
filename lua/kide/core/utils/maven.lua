local utils = require("kide.core.utils")
local M = {}

local function maven_settings()
  local maven_home = vim.env["MAVEN_HOME"]
  if maven_home then
    return maven_home .. "/conf/settings.xml"
  end
end

M.get_maven_settings = function()
  return vim.env["MAVEN_SETTINGS"] or maven_settings()
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

local exec = function(cmd, pom, opt)
  opt = opt or {}
  local Terminal = require("toggleterm.terminal").Terminal
  -- require("toggleterm").exec(cmd .. settings_opt(M.get_maven_settings()) .. pom_file(pom))
  local mvn = Terminal:new({
    cmd = cmd .. settings_opt(M.get_maven_settings()) .. pom_file(pom),
    close_on_exit = opt.close_on_exit,
    auto_scroll = true,
    on_exit = function(_)
      if opt.update ~= nil and opt.update and opt.close_on_exit ~= nil and opt.close_on_exit then
        vim.defer_fn(function()
          local filetype = vim.api.nvim_buf_get_option(0, "filetype")
          if filetype == "java" then
            require("jdtls").update_project_config()
          end
        end, 500)
      end
    end,
  })
  mvn:toggle()
end
local function create_command(buf, name, cmd, complete, opt)
  vim.api.nvim_buf_create_user_command(buf, name, function(opts)
    if opts.args then
      exec(cmd .. " " .. opts.args, vim.fn.expand("%"), opt)
    else
      exec(cmd, vim.fn.expand("%"), opt)
    end
  end, {
    nargs = "*",
    complete = complete,
  })
end

local maven_args_complete = utils.command_args_complete

M.maven_command = function(buf)
  create_command(
    buf,
    "MavenCompile",
    "mvn clean compile",
    maven_args_complete({ "test-compile" }, { multiple = true }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenInstll",
    "mvn clean install",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { single = true }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenPackage",
    "mvn clean package",
    maven_args_complete({ "-DskipTests", "-Dmaven.test.skip=true" }, { single = true }),
    { update = true, close_on_exit = false }
  )
  create_command(
    buf,
    "MavenDependencyTree",
    "mvn dependency:tree",
    maven_args_complete({ "-Doutput=.dependency.txt" }, { multiple = true }),
    { close_on_exit = false }
  )
  create_command(buf, "MavenDependencyAnalyzeDuplicate", "mvn dependency:analyze-duplicate", nil, {
    close_on_exit = false,
  })
  create_command(buf, "MavenDependencyAnalyzeOnly", "mvn dependency:analyze-only -Dverbose", nil, {
    close_on_exit = false,
  })
  create_command(buf, "MavenDownloadSources", "mvn dependency:sources -DdownloadSources=true")
  create_command(buf, "MavenTest", "mvn test", maven_args_complete({ "-Dtest=" }, {}), { close_on_exit = false })
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
end
return M
