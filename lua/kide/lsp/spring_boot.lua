local vscode = require("kide.core.vscode")
local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }) or vim.loop.cwd()

local function spring_boot_ls_launcher()
  local bootls_path = vscode.find_one("/vmware.vscode-spring-boot-*/language-server")
  local classpath = {}
  table.insert(classpath, bootls_path .. "/BOOT-INF/classes")
  table.insert(classpath, bootls_path .. "/BOOT-INF/lib/*")

  local cmd = {
    "java",
    "-XX:TieredStopAtLevel=1",
    "-Xmx1G",
    "-XX:+UseZGC",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-cp",
    table.concat(classpath, ":"),
    "-Dsts.lsp.client=vscode",
    "-Dsts.log.file=" .. root_dir .. "/.spring-boot-ls.log",
    "-Dspring.config.location=file:" .. bootls_path .. "/BOOT-INF/classes/application.properties",
    "org.springframework.ide.vscode.boot.app.BootLanguageServerBootApp",
  }

  -- table.insert(cmd, "org.springframework.ide.vscode.concourse.ConcourseLanguageServerBootApp")
  return cmd
end

local config = {
  cmd = spring_boot_ls_launcher(),
  name = "spring-boot",
  filetypes = { "java", "yaml" },
  root_dir = root_dir,
  init_options = {
    workspaceFolders = root_dir,
    enableJdtClasspath = true,
  },
  settings = {
    spring_boot = {},
  },
  handlers = {},
}

config["on_attach"] = function(client, buffer)
  print("Attaching to spring-boot")
end

--[[

(defun lsp-java-boot--sts-add-classpath-listener (_workspace params)
  "Add classpath listener for WORKSPACE with PARAMS data."
  (ignore
   (with-lsp-workspace (lsp-find-workspace 'jdtls nil)
     (lsp-request "workspace/executeCommand"
                  (list :command "sts.java.addClasspathListener"
                        :arguments (lsp-get params :callbackCommandId))
                  :no-wait t))))
]]
config.handlers["sts/addClasspathListener"] = function(_, result)
  print("sts/addClasspathListener")
  print(vim.inspect(result))
  local err, resp = require("kide.lsp.utils.jdtls").execute_command({
    command = "sts.java.addClasspathListener",
    arguments = { result.callbackCommandId },
  }, nil, 0)
  if err then
    print("Error executing command")
    print(vim.inspect(err))
  end
  print(vim.inspect(resp))
  return err, resp
end

config.handlers["sts/removeClasspathListener"] = function(_, result)
  print("sts/removeClasspathListener")
  print(vim.inspect(result))
end
--[[
(defun lsp-java-boot--sts-javadoc-hover-link (_workspace params)
  "Handler with PARAMS data for java doc hover."
  (with-lsp-workspace (lsp-find-workspace 'jdtls nil)
    (lsp-request "workspace/executeCommand"
                 (list :command "sts.java.addClasspathListener"
                       :arguments (lsp-get params :callbackCommandId))
                 :no-wait t)))
]]
config.handlers["sts/javadocHoverLink"] = function(_, result)
  print("sts/javadocHoverLink")
  print(vim.inspect(result))
  return require("kide.lsp.utils.jdtls").execute_command({
    command = "sts.java.javadocHoverLink",
    arguments = { result.callbackCommandId },
  })
end

config.handlers["sts/progress"] = function(err, result, ctx, config)
  print("sts/progress")
  print(vim.inspect(result))
end

config.handlers["sts/javaSuperTypes"] = function(err, result, ctx, config)
  print("sts/javaSuperTypes")
  print(vim.inspect(result))
end
config.handlers["sts/highlight"] = function() end

local M = {}
local initialized = false
M.setup = function(opts, mode)
  if not (mode == "jdtls") then
    return
  end
  if initialized then
    return
  end
  initialized = true
  config.flags = opts.flags

  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.workspace = {
    executeCommand = { value = true },
  }
  config.capabilities = capabilities
  local group = vim.api.nvim_create_augroup("kide_spring_boot_java", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "java", "yaml" },
    desc = "Spring Boot Language Server",
    callback = function(e)
      if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
        -- ignore
      else
        vim.lsp.start(config)
      end
    end,
  })
end
return M
