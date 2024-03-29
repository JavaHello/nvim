local M = {}
local env = {
  HOME = vim.env["HOME"],
  JAVA_HOME = vim.env["JAVA_HOME"],
  JDTLS_RUN_JAVA = vim.env["JDTLS_RUN_JAVA"],
  JDTLS_HOME = vim.env["JDTLS_HOME"],
  JDTLS_WORKSPACE = vim.env["JDTLS_WORKSPACE"],
  JOL_JAR = vim.env["JOL_JAR"],
}
local maven = require("kide.core.utils.maven")

local jdtls_java = (function()
  local jdtls_run_java = env.JDTLS_RUN_JAVA
  if jdtls_run_java then
    return jdtls_run_java
  end
  local java_home = env.JAVA_HOME
  if java_home then
    return java_home .. "/bin/java"
  end
  return "java"
end)()
local utils = require("kide.core.utils")
local function or_default(a, v)
  return utils.or_default(a, v)
end

local function get_java_ver_home(v, dv)
  return vim.env["JAVA_" .. v .. "_HOME"] or dv
end
local function get_java_ver_sources(v, dv)
  return vim.env["JAVA_" .. v .. "_SOURCES"] or dv
end

local function get_jdtls_workspace()
  return or_default(env.JDTLS_WORKSPACE, env.HOME .. "/.jdtls-workspace/")
end

local vscode = require("kide.core.vscode")

local function get_jol_jar()
  return env.JOL_JAR or "/opt/software/java/jol-cli-0.16-full.jar"
end

-- see https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
local ExecutionEnvironment = {
  J2SE_1_5 = "J2SE-1.5",
  JavaSE_1_6 = "JavaSE-1.6",
  JavaSE_1_7 = "JavaSE-1.7",
  JavaSE_1_8 = "JavaSE-1.8",
  JavaSE_9 = "JavaSE-9",
  JavaSE_10 = "JavaSE-10",
  JavaSE_11 = "JavaSE-11",
  JavaSE_12 = "JavaSE-12",
  JavaSE_13 = "JavaSE-13",
  JavaSE_14 = "JavaSE-14",
  JavaSE_15 = "JavaSE-15",
  JavaSE_16 = "JavaSE-16",
  JavaSE_17 = "JavaSE-17",
  JavaSE_18 = "JavaSE-18",
  JavaSE_19 = "JavaSE-19",
}

local function fglob(path)
  if path == "" then
    return nil
  end
  return path
end

local runtimes = (function()
  local result = {}
  for _, value in pairs(ExecutionEnvironment) do
    local version = vim.fn.split(value, "-")[2]
    if string.match(version, "%.") then
      version = vim.split(version, "%.")[2]
    end
    local java_home = get_java_ver_home(version)
    local default_jdk = false
    if java_home then
      local java_sources = get_java_ver_sources(
        version,
        fglob(vim.fn.glob(java_home .. "/src.zip")) or fglob(vim.fn.glob(java_home .. "/lib/src.zip"))
      )
      if ExecutionEnvironment.JavaSE_17 == value then
        default_jdk = true
      end
      table.insert(result, {
        name = value,
        path = java_home,
        sources = java_sources,
        default = default_jdk,
      })
    end
  end
  if #result == 0 then
    vim.notify("Please config Java runtimes (JAVA_17_HOME...)")
  end
  return result
end)()

-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
local rwdir = root_dir or vim.fn.getcwd()
local workspace_dir = get_jdtls_workspace() .. require("kide.core.utils.md5").sumhexa(rwdir)
-- local jdtls_path = vscode.find_one("/redhat.java-*/server")
local function get_jdtls_path()
  return or_default(env.JDTLS_HOME, vscode.find_one("/redhat.java-*/server"))
end

local function jdtls_launcher()
  local jdtls_path = get_jdtls_path()
  if jdtls_path then
  elseif require("mason-registry").has_package("jdtls") then
    jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()
  end
  local utils = require("kide.core.utils")
  local jdtls_config = nil
  if utils.is_mac then
    jdtls_config = "/config_mac"
  elseif utils.is_linux then
    jdtls_config = "/config_linux"
  elseif utils.is_win then
    jdtls_config = "/config_win"
  else
    vim.notify("jdtls: unknown os", vim.log.levels.ERROR)
    return nil
  end
  local lombok_jar = vscode.get_lombok_jar()
  local cmd = {
    jdtls_java,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dosgi.checkConfiguration=true",
    "-Dosgi.sharedConfiguration.area=" .. vim.fn.glob(jdtls_path .. jdtls_config),
    "-Dosgi.sharedConfiguration.area.readOnly=true",
    "-Dosgi.configuration.cascaded=true",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx4g",
    "-XX:+UseZGC",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
  }
  if lombok_jar ~= nil then
    table.insert(cmd, "-javaagent:" .. lombok_jar)
  end
  table.insert(cmd, "-jar")
  table.insert(cmd, vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"))
  table.insert(cmd, "-data")
  table.insert(cmd, workspace_dir)
  return cmd
end

local bundles = {}
-- This bundles definition is the same as in the previous section (java-debug installation)

local vscode_java_debug_path = (function()
  local p = vscode.find_one("/vscjava.vscode-java-debug-*/server")
  if p then
    return p
  end
  if require("mason-registry").has_package("java-debug-adapter") then
    return require("mason-registry").get_package("java-debug-adapter"):get_install_path() .. "/extension/server"
  end
end)()
if vscode_java_debug_path then
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(vscode_java_debug_path .. "/com.microsoft.java.debug.plugin-*.jar"), "\n")
  )
end

-- /opt/software/lsp/java/vscode-java-test/server
-- vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-test/server/*.jar"), "\n"));
local vscode_java_test_path = (function()
  local p = vscode.find_one("/vscjava.vscode-java-test-*/server")
  if p then
    return p
  end
  if require("mason-registry").has_package("java-test") then
    return require("mason-registry").get_package("java-test"):get_install_path() .. "/extension/server"
  end
end)()
if vscode_java_test_path then
  for _, bundle in ipairs(vim.split(vim.fn.glob(vscode_java_test_path .. "/*.jar"), "\n")) do
    if not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar") then
      table.insert(bundles, bundle)
    end
  end
end

-- /opt/software/lsp/java/vscode-java-decompiler/server/
local java_decoompiler_path = vscode.find_one("/dgileadi.java-decompiler-*/server")
if java_decoompiler_path then
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_decoompiler_path .. "/*.jar"), "\n"))
end

-- /opt/software/lsp/java/vscode-java-dependency/jdtls.ext/
-- vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-dependency/jdtls.ext/com.microsoft.jdtls.ext.core/target/com.microsoft.jdtls.ext.core-*.jar"), "\n"));
-- /opt/software/lsp/java/vscode-java-dependency/server/
local java_dependency_path = vscode.find_one("/vscjava.vscode-java-dependency-*/server")
if java_dependency_path then
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_dependency_path .. "/*.jar"), "\n"))
end

local vscode_pde_path = vscode.find_one("/yaozheng.vscode-pde-*/server")
if vscode_pde_path then
  vim.list_extend(bundles, vim.split(vim.fn.glob(vscode_pde_path .. "/*.jar"), "\n"))
end

-- vim.notify("SETUP: " .. vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), vim.log.levels.INFO)
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = jdtls_launcher(),
  filetypes = { "java" },
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      autobuild = { enabled = true },
      maxConcurrentBuilds = utils.get_cpu_thread_count(),
      home = env.JAVA_HOME,
      project = {
        encoding = "UTF-8",
      },
      foldingRange = { enabled = true },
      selectionRange = { enabled = true },
      import = {
        gradle = { enabled = true },
        maven = { enabled = true },
        exclusions = {
          "**/node_modules/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/maven/**",
          "**/.git/**",
        },
      },
      inlayhints = {
        parameterNames = { enabled = true },
      },
      referenceCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
      templates = {
        fileHeader = {
          "/**",
          " * ${type_name}",
          " * @author ${user}",
          " */",
        },
        typeComment = {
          "/**",
          " * ${type_name}",
          " * @author ${user}",
          " */",
        },
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
        updateSnapshots = true,
      },
      signatureHelp = {
        enabled = true,
        description = {
          enabled = true,
        },
      },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.assertj.core.api.Assertions.assertThat",
          "org.assertj.core.api.Assertions.assertThatThrownBy",
          "org.assertj.core.api.Assertions.assertThatExceptionOfType",
          "org.assertj.core.api.Assertions.catchThrowable",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "org.graalvm.*",
          "jdk.*",
          "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      configuration = {
        maven = {
          userSettings = maven.get_maven_settings(),
          globalSettings = maven.get_maven_settings(),
        },
        runtimes = runtimes,
      },
    },
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  -- init_options = {
  --   bundles = {
  --     vim.fn.glob("/opt/software/lsp/java/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.35.0.jar")
  --   },
  --   workspace = workspace_dir
  -- },
}

local jdtls = require("jdtls")
jdtls.jol_path = get_jol_jar()

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
extendedClientCapabilities.progressReportProvider = false

config["init_options"] = {
  bundles = bundles,
  extendedClientCapabilities = extendedClientCapabilities,
}

M.async_profiler_home = vim.env["ASYNC_PROFILER_HOME"]
local function get_async_profiler_ddl()
  if M.async_profiler_home then
    if utils.is_mac then
      return vim.fn.glob(M.async_profiler_home .. "/build/lib/libasyncProfiler.dylib")
    elseif utils.is_linux then
      return vim.fn.glob(M.async_profiler_home .. "/build/lib/libasyncProfiler.so")
    else
      return vim.fn.glob(M.async_profiler_home .. "/build/lib/libasyncProfiler.dll")
    end
  end
end
local function get_async_profiler_cov()
  if M.async_profiler_home then
    return vim.fn.glob(M.async_profiler_home .. "/target/async-profiler-converter-3.0.jar")
  end
end

-- see https://github.com/mfussenegger/dotfiles/blob/master/vim/.config/nvim/ftplugin/java.lua
local function test_with_profile(test_fn)
  return function()
    local choices = {
      "cpu,alloc=2m,lock=10ms",
      "cpu",
      "alloc",
      "wall",
      "context-switches",
      "cycles",
      "instructions",
      "cache-misses",
    }
    local select_opts = {
      format_item = tostring,
    }
    vim.ui.select(choices, select_opts, function(choice)
      if not choice then
        return
      end
      local async_profiler_so = get_async_profiler_ddl()
      local event = "event=" .. choice
      local vmArgs = "-ea -agentpath:" .. async_profiler_so .. "=start,"
      vmArgs = vmArgs .. event .. ",file=" .. utils.tmpdir_file("profile.jfr")
      test_fn({
        config_overrides = {
          vmArgs = vmArgs,
          noDebug = true,
        },
        after_test = function()
          vim.fn.system(
            "java -jar "
              .. get_async_profiler_cov()
              .. " jfr2flame "
              .. utils.tmpdir_file("profile.jfr")
              .. " "
              .. utils.tmpdir_file("profile.html")
          )
          utils.open_fn(utils.tmpdir_file("profile.html"))
        end,
      })
    end)
  end
end

config["on_attach"] = function(client, buffer)
  -- client.server_capabilities.semanticTokensProvider = nil
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  require("jdtls").setup_dap({ hotcodereplace = "auto" })
  require("jdtls.setup").add_commands()
  -- TODO: 不知道为什么这个值一会有一会没有
  client.server_capabilities["definitionProvider"] = true
  -- require('jdtls.dap').setup_dap_main_class_configs({ verbose = true })
  local opts = { silent = true, buffer = buffer }
  local function desc_opts(desc)
    return { silent = true, buffer = buffer, desc = desc }
  end

  local function with_compile(fn)
    return function()
      if vim.bo.modified then
        vim.cmd("w")
      end
      client.request_sync("java/buildWorkspace", false, 5000, buffer)
      fn()
    end
  end
  vim.keymap.set("n", "<leader>dc", with_compile(jdtls.test_class), desc_opts("Test class"))
  vim.keymap.set("n", "<leader>dm", with_compile(jdtls.test_nearest_method), desc_opts("Test method"))
  vim.keymap.set("n", "<leader>ds", with_compile(jdtls.pick_test), desc_opts("Select test"))
  vim.keymap.set("n", "crv", jdtls.extract_variable, desc_opts("Extract variable"))
  vim.keymap.set("v", "crm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc_opts("Extract method"))
  vim.keymap.set("n", "crc", jdtls.extract_constant, desc_opts("Extract constant"))

  if M.async_profiler_home then
    vim.keymap.set(
      "n",
      "<leader>dM",
      with_compile(test_with_profile(jdtls.test_nearest_method)),
      desc_opts("Test method with profiling")
    )
  end

  local create_command = vim.api.nvim_buf_create_user_command
  create_command(buffer, "OR", require("jdtls").organize_imports, {
    nargs = 0,
  })

  require("java-deps").attach(client, buffer, root_dir)
  create_command(buffer, "JavaProjects", require("java-deps").toggle_outline, {
    nargs = 0,
  })
  -- vim.notify(vim.api.nvim_buf_get_name(bufnr), vim.log.levels.INFO)

  create_command(
    buffer,
    "JdtRun",
    with_compile(function()
      local main_config_opts = {
        verbose = false,
        on_ready = require("dap").continue,
      }
      require("jdtls.dap").setup_dap_main_class_configs(main_config_opts)
    end),
    {
      nargs = 0,
    }
  )
end

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
-- capabilities.experimental = {
--   hoverActions = true,
--   hoverRange = true,
--   serverStatusNotification = true,
--   snippetTextEdit = true,
--   codeActionGroup = true,
--   ssr = true,
-- }

config.capabilities = capabilities
config.flags = {
  debounce_text_changes = 150,
}
config.handlers = {}
config.handlers["language/status"] = function(_, s)
  -- 使用 progress 查看状态
  -- print("jdtls " .. s.type .. ": " .. s.message)
  if "ServiceReady" == s.type then
    require("jdtls.dap").setup_dap_main_class_configs({ verbose = true })
  end
end

M.config = config
M.start = function(_)
  jdtls.start_or_attach(config)
end

M.setup = function(opts)
  require("kide.lsp.utils.jdtls").customize_jdtls()
  local group = vim.api.nvim_create_augroup("kide_jdtls_java", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "java" },
    desc = "jdtls",
    callback = function(e)
      if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
        -- ignore
      else
        M.start(opts)
      end
    end,
  })
end

return M
