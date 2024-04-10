local M = {}
local initialized = false
if "Y" == vim.env["SPRING_BOOT_LS_ENABLE"] then
  local vscode = require("kide.core.vscode")
  local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }) or vim.loop.cwd()
  local bootls_path = vscode.find_one("/vmware.vscode-spring-boot-*/language-server")
  local utils = require("kide.core.utils")

  local function spring_boot_ls_launcher()
    if not bootls_path then
      return
    end
    local classpath = {}
    table.insert(classpath, bootls_path .. "/BOOT-INF/classes")
    table.insert(classpath, bootls_path .. "/BOOT-INF/lib/*")

    local cmd = {
      utils.java_bin(),
      "-XX:TieredStopAtLevel=1",
      "-Xmx1G",
      "-XX:+UseZGC",
      "-cp",
      table.concat(classpath, utils.is_win and ";" or ":"),
      "-Dsts.lsp.client=vscode",
      "-Dsts.log.file=" .. root_dir .. "/.spring-boot-ls.log",
      "-Dspring.config.location=file:" .. bootls_path .. "/BOOT-INF/classes/application.properties",
      -- "-Dlogging.level.org.springframework=DEBUG",
      "org.springframework.ide.vscode.boot.app.BootLanguageServerBootApp",
    }

    -- table.insert(cmd, "org.springframework.ide.vscode.concourse.ConcourseLanguageServerBootApp")
    return cmd
  end

  local is_application_yml_file = function(filename)
    local r = string.match(filename, "application.*%.ya?ml$") or string.match(filename, "bootstrap.*%.ya?ml$")
    return r ~= nil
  end

  local is_application_properties_file = function(filename)
    local r = string.match(filename, "application.*%.properties$") or string.match(filename, "bootstrap.*%.properties$")
    return r ~= nil
  end

  local is_application_properties_buf = function(bufnr)
    local rfilename = vim.api.nvim_buf_get_name(bufnr)
    return is_application_properties_file(rfilename)
  end

  local is_application_yml_buf = function(bufnr)
    local rfilename = vim.api.nvim_buf_get_name(bufnr)
    return is_application_yml_file(rfilename)
  end

  local config = {
    cmd = spring_boot_ls_launcher(),
    name = "spring-boot",
    filetypes = { "java", "yaml", "jproperties" },
    root_dir = root_dir,
    init_options = {
      workspaceFolders = root_dir,
      enableJdtClasspath = false,
    },
    settings = {
      spring_boot = {},
    },
    handlers = {},
    commands = {},
    get_language_id = function(bufnr, filetype)
      if filetype == "yaml" then
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if is_application_yml_file(filename) then
          return "spring-boot-properties-yaml"
        end
      elseif filetype == "jproperties" then
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if is_application_properties_file(filename) then
          return "spring-boot-properties"
        end
      end
      return filetype
    end,
  }

  config["on_attach"] = function(client, buffer)
    local filename = vim.api.nvim_buf_get_name(buffer)
    if is_application_properties_file(filename) or is_application_yml_file(filename) then
      client.server_capabilities.hoverProvider = true
    else
      client.server_capabilities.hoverProvider = false
    end
  end

  config["on_init"] = function(client, _)
    -- see jdtls on_init
    -- client.request("workspace/executeCommand", {
    --   command = "sts.vscode-spring-boot.enableClasspathListening",
    --   arguments = { true },
    -- }, function(err, _)
    --   if err then
    --     vim.notify("Error enabling classpath listening", vim.log.levels.ERROR)
    --   end
    -- end, 0)
  end

  local jdtls_execute_command = function(command, result)
    local err, resp = require("jdtls.util").execute_command({
      command = command,
      arguments = result,
    })
    if err then
      vim.notify("Error executeCommand: " .. command, vim.log.levels.ERROR)
    end
    return resp
  end

  config.handlers["sts/addClasspathListener"] = function(_, result)
    local jdtls_client = vim.lsp.get_active_clients({ name = "jdtls" })
    if not jdtls_client or #jdtls_client == 0 then
      print("jdtls not found")
      return "ok"
    end

    local err, resp = require("jdtls.util").execute_command({
      command = "sts.java.addClasspathListener",
      arguments = { result.callbackCommandId },
    })
    if err then
      vim.notify("Error adding classpath listener", vim.log.levels.ERROR)
    else
      vim.lsp.commands[result.callbackCommandId] = function(param, ctx)
        local client = vim.lsp.get_active_clients({ name = "spring-boot" })[1]

        local ir = client.request_sync("workspace/executeCommand", {
          command = result.callbackCommandId,
          arguments = param,
        })
        return ir
      end
    end

    return resp
  end

  config.handlers["sts/removeClasspathListener"] = function(_, result)
    local err, resp = require("kide.lsp.utils.jdtls").execute_command({
      command = "sts.java.removeClasspathListener",
      arguments = { result.callbackCommandId },
    }, nil)
    if err then
      vim.notify("Error adding classpath listener", vim.log.levels.ERROR)
    end
    return resp
  end

  -- --------------------------------
  config.handlers["sts/javaType"] = function(err, result)
    if err then
      vim.notify("Error getting java type", vim.log.levels.ERROR)
      return
    end
    return jdtls_execute_command("sts.java.type", result)
  end
  config.handlers["sts/javaCodeComplete"] = function(err, result)
    if err then
      vim.notify("Error getting java code complete", vim.log.levels.ERROR)
      return
    end
    return jdtls_execute_command("sts.java.code.completions", result)
  end

  config.handlers["sts/javadocHoverLink"] = function(_, result)
    print("sts/javadocHoverLink")
    print(vim.inspect(result))
  end

  config.handlers["sts/javaLocation"] = function(err, result, ctx, config)
    print("sts/javaLocation")
    print(vim.inspect(result))
  end

  config.handlers["sts/javadoc"] = function(err, result, ctx, config)
    print("sts/javadoc")
    print(vim.inspect(result))
  end

  config.handlers["sts/javaSearchTypes"] = function(err, result, ctx, config)
    print("sts/javaSearchTypes")
    print(vim.inspect(result))
  end

  config.handlers["sts/javaSearchPackages"] = function(err, result, ctx, config)
    print("sts/javaSearchPackages")
    print(vim.inspect(result))
  end

  config.handlers["sts/javaSubTypes"] = function(err, result, ctx, config)
    print("sts/javaSubTypes")
    print(vim.inspect(result))
  end

  config.handlers["sts/javaSuperTypes"] = function(err, result, ctx, config)
    print("sts/javaSuperTypes")
    print(vim.inspect(result))
  end

  config.handlers["sts/progress"] = function(err, result, ctx, config)
    print("sts/progress")
    print(vim.inspect(result))
  end

  config.handlers["sts/highlight"] = function() end
  config.handlers["sts/moveCursor"] = function(err, result, ctx, config)
    -- TODO: move cursor
    return { applied = true }
  end

  M.setup = function(opts)
    if initialized then
      return
    end
    initialized = true
    if not bootls_path then
      return
    end

    config.flags = opts.flags

    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.workspace = {
      executeCommand = { value = true },
    }
    config.capabilities = capabilities
    local group = vim.api.nvim_create_augroup("kide_spring_boot_java", { clear = true })
    vim.api.nvim_create_autocmd({ "FileType" }, {
      group = group,
      pattern = { "java", "yaml", "jproperties" },
      desc = "Spring Boot Language Server",
      callback = function(e)
        if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
          return
        end
        if vim.endswith(e.file, "pom.xml") then
          return
        end
        vim.lsp.start(config)
      end,
    })
  end
end

-- 参考资料
-- https://github.com/spring-projects/sts4/issues/76
-- https://github.com/spring-projects/sts4/issues/1128
-- https://github.com/emacs-lsp/lsp-java/blob/master/lsp-java-boot.el
return M
