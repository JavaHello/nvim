local M = {}
local cutils = require("kide.core.utils")
local env = {
  HOME = vim.loop.os_homedir(),
  JAVA_HOME = os.getenv("JAVA_HOME"),
  MAVEN_HOME = os.getenv("MAVEN_HOME"),
  MAVEN_SETTINGS = os.getenv("MAVEN_SETTINGS"),
  JDTLS_HOME = os.getenv("JDTLS_HOME"),
  JDTLS_WORKSPACE = os.getenv("JDTLS_WORKSPACE"),
  LOMBOK_JAR = os.getenv("LOMBOK_JAR"),
}

local function or_default(a, v)
  return require("kide.core.utils").or_default(a, v)
end

local maven_settings = env.MAVEN_HOME .. "/conf/settings.xml"
local function get_maven_settings()
  return or_default(env.MAVEN_SETTINGS, maven_settings)
end

local function get_java_home()
  return or_default(env.JAVA_HOME, "/opt/software/java/zulu17.34.19-ca-jdk17.0.3-macosx_aarch64")
end
local function get_java_ver_home(v, dv)
  return os.getenv("JAVA_" .. v .. "_HOME") or dv
end

local function get_java()
  return get_java_home() .. "/bin/java"
end

local function get_jdtls_workspace()
  return or_default(env.JDTLS_WORKSPACE, env.HOME .. "/jdtls-workspace/")
end

local vscode = require("kide.core.vscode")
local function get_lombok_jar()
  return or_default(env.LOMBOK_JAR, "/opt/software/lsp/lombok.jar")
end

local _config = (function()
  if cutils.os_type() == cutils.Windows then
    return "config_win"
  elseif cutils.os_type() == cutils.Mac then
    return "config_mac"
  else
    return "config_linux"
  end
end)()

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_dir = get_jdtls_workspace() .. project_name
-- local jdtls_path = vscode.find_one("/redhat.java-*/server")
local function get_jdtls_path()
  return or_default(env.JDTLS_HOME, vscode.find_one("/redhat.java-*/server"))
end
local jdtls_path = get_jdtls_path()

local jdtls_launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local jdtls_config = vim.fn.glob(jdtls_path .. "/" .. _config)

local bundles = {}
-- This bundles definition is the same as in the previous section (java-debug installation)
local vscode_java_debug_path = vscode.find_one("/vscjava.vscode-java-debug-*/server")
vim.list_extend(
  bundles,
  vim.split(vim.fn.glob(vscode_java_debug_path .. "/com.microsoft.java.debug.plugin-*.jar"), "\n")
)

-- /opt/software/lsp/java/vscode-java-test/server
-- vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-test/server/*.jar"), "\n"));
local vscode_java_test_path = vscode.find_one("/vscjava.vscode-java-test-*/server")
for _, bundle in ipairs(vim.split(vim.fn.glob(vscode_java_test_path .. "/*.jar"), "\n")) do
  if not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar") then
    table.insert(bundles, bundle)
  end
end

-- /opt/software/lsp/java/vscode-java-decompiler/server/
local java_decoompiler_path = vscode.find_one("/dgileadi.java-decompiler-*/server")
vim.list_extend(bundles, vim.split(vim.fn.glob(java_decoompiler_path .. "/*.jar"), "\n"))

-- /opt/software/lsp/java/vscode-java-dependency/jdtls.ext/
-- vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-dependency/jdtls.ext/com.microsoft.jdtls.ext.core/target/com.microsoft.jdtls.ext.core-*.jar"), "\n"));
-- /opt/software/lsp/java/vscode-java-dependency/server/
local java_dependency_path = vscode.find_one("/vscjava.vscode-java-dependency-*/server")
vim.list_extend(bundles, vim.split(vim.fn.glob(java_dependency_path .. "/*.jar"), "\n"))

local vscode_pde_path = vscode.find_one("/yaozheng.vscode-pde-*/server")
if vscode_pde_path then
  vim.list_extend(bundles, vim.split(vim.fn.glob(vscode_pde_path .. "/*.jar"), "\n"))
end

local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })

-- vim.notify("SETUP: " .. vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), vim.log.levels.INFO)
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    get_java(), -- or '/path/to/java11_or_newer/bin/java'
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    -- "-Dosgi.configuration.cascaded=true",
    -- "-Dosgi.sharedConfiguration.area=" .. get_jdtls_home() .. "/config_mac",
    -- "-Dosgi.sharedConfiguration.area.readOnly=true",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Dsun.zip.disableMemoryMapping=true",
    -- "-noverify",
    -- '-XX:+UseParallelGC',
    -- '-XX:GCTimeRatio=4',
    -- '-XX:AdaptiveSizePolicyWeight=90',
    -- '-XX:+UseG1GC',
    -- '-XX:+UseStringDeduplication',
    -- '-Xms512m',
    "-XX:+UseZGC",
    "-Xmx4g",
    -- "-Xbootclasspath/a:" .. get_lombok_jar(),
    "-javaagent:" .. get_lombok_jar(),
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    jdtls_launcher,
    "-configuration",
    jdtls_config,
    "-data",
    workspace_dir,
  },
  filetypes = { "java" },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      maxConcurrentBuilds = 8,
      home = get_java_home(),
      project = {
        encoding = "UTF-8",
        resourceFilters = {
          "node_modules",
          ".git",
          ".idea",
        },
      },
      import = {
        exclusions = {
          "**/node_modules/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/maven/**",
          "**/.git/**",
          "**/.idea/**",
        },
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
      server = {
        launchMode = "Hybrid",
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
          "org.junit.Assert.*",
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
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
          --          userSettings = "/opt/software/apache-maven-3.6.3/conf/settings.xml",
          --          globalSettings = "/opt/software/apache-maven-3.6.3/conf/settings.xml",
          userSettings = get_maven_settings(),
          globalSettings = get_maven_settings(),
        },
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = get_java_ver_home("8", "/opt/software/java/zulu8.62.0.19-ca-jdk8.0.332-macosx_aarch64"),
            default = true,
          },
          {
            name = "JavaSE-11",
            path = get_java_ver_home("11", "/opt/software/java/zulu11.56.19-ca-jdk11.0.15-macosx_aarch64"),
          },
          {
            name = "JavaSE-17",
            path = get_java_ver_home("17", "/opt/software/java/graalvm-ce-java17-22.1.0/Contents/Home"),
          },
        },
      },
      -- referencesCodeLens = {
      --   enabled = true,
      -- },
      -- implementationsCodeLens = {
      --   enabled = true,
      -- },
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

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
extendedClientCapabilities.progressReportProvider = false

config["init_options"] = {
  bundles = bundles,
  extendedClientCapabilities = extendedClientCapabilities,
}

config["on_attach"] = function(client, buffer)
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  require("jdtls").setup_dap({ hotcodereplace = "auto" })
  require("jdtls.setup").add_commands()
  require("kide.core.keybindings").maplsp(client, buffer)
  -- require('jdtls.dap').setup_dap_main_class_configs({ verbose = true })
  local opts = { silent = true, buffer = buffer }
  vim.keymap.set("n", "<leader>dc", jdtls.test_class, opts)
  vim.keymap.set("n", "<leader>dm", jdtls.test_nearest_method, opts)
  vim.keymap.set("n", "crv", jdtls.extract_variable, opts)
  vim.keymap.set("v", "crm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
  vim.keymap.set("n", "crc", jdtls.extract_constant, opts)
  local create_command = vim.api.nvim_buf_create_user_command
  create_command(buffer, "OR", require("jdtls").organize_imports, {
    nargs = 0,
  })
  -- if vim.g.jdtls_dap_main_class_config_init then
  --   vim.defer_fn(function()
  --     require("jdtls.dap").setup_dap_main_class_configs({ verbose = true })
  --   end, 3000)
  --   vim.g.jdtls_dap_main_class_config_init = false
  -- end

  require("nvim-navic").attach(client, buffer)
  -- require('java-deps').attach(client, bufnr)
  -- vim.notify(vim.api.nvim_buf_get_name(bufnr), vim.log.levels.INFO)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- capabilities.experimental = {
--   hoverActions = true,
--   hoverRange = true,
--   serverStatusNotification = true,
--   snippetTextEdit = true,
--   codeActionGroup = true,
--   ssr = true,
-- }

config.capabilities = capabilities
config.handlers = {}
config.handlers["language/status"] = function(_, s)
  -- 使用 progress 查看状态
  -- print("jdtls " .. s.type .. ": " .. s.message)
  if "ServiceReady" == s.type then
    require("jdtls.dap").setup_dap_main_class_configs({ verbose = true })
  end
end

-- java 暂时兼容 fidget, 等待上游支持
vim.lsp.handlers["$/progress"] = nil
require("fidget").setup({})

local function markdown_format(input)
  if input then
    -- input = string.gsub(input, "[\r\n]( +)(%*)", function (i1)
    --   return i1 .. "-"
    -- end)
    input = string.gsub(input, "%[([^:/]*)%]", function(i1)
      return "`" .. i1 .. "`"
    end)
    input = string.gsub(input, "%(file:/[^%)]+%)", "")
    input = string.gsub(input, "%(jdt://[^%)]+%)", "")
  end
  return input
end

local function split_lines(value)
  value = string.gsub(value, "\r\n?", "\n")
  return vim.split(value, "\n", true)
end
function M.convert_input_to_markdown_lines(input, contents)
  contents = contents or {}
  -- MarkedString variation 1
  if type(input) == "string" then
    input = markdown_format(input)
    vim.list_extend(contents, split_lines(input))
  else
    assert(type(input) == "table", "Expected a table for Hover.contents")
    -- MarkupContent
    if input.kind then
      -- The kind can be either plaintext or markdown.
      -- If it's plaintext, then wrap it in a <text></text> block

      -- Some servers send input.value as empty, so let's ignore this :(
      local value = input.value or ""

      if input.kind == "plaintext" then
        -- wrap this in a <text></text> block so that stylize_markdown
        -- can properly process it as plaintext
        value = string.format("<text>\n%s\n</text>", value)
      end

      -- assert(type(value) == 'string')
      vim.list_extend(contents, split_lines(value))
      -- MarkupString variation 2
    elseif input.language then
      -- Some servers send input.value as empty, so let's ignore this :(
      -- assert(type(input.value) == 'string')
      table.insert(contents, "```" .. input.language)
      vim.list_extend(contents, split_lines(input.value or ""))
      table.insert(contents, "```")
      -- By deduction, this must be MarkedString[]
    else
      -- Use our existing logic to handle MarkedString
      for _, marked_string in ipairs(input) do
        M.convert_input_to_markdown_lines(marked_string, contents)
      end
    end
  end
  if (contents[1] == "" or contents[1] == nil) and #contents == 1 then
    return {}
  end
  return contents
end

local function jhover(_, result, ctx, c)
  c = c or {}
  c.focus_id = ctx.method
  c.stylize_markdown = true
  if not (result and result.contents) then
    vim.notify("No information available")
    return
  end
  local markdown_lines = M.convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    vim.notify("No information available")
    return
  end
  local b, w = vim.lsp.util.open_floating_preview(markdown_lines, "markdown", c)
  -- vim.api.nvim_win_set_option(w, "winblend", 10)
  return b, w
end

local lsp_ui = require("kide.lsp.lsp_ui")
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(jhover, lsp_ui.hover_actions)
local source = require("cmp_nvim_lsp.source")
source.resolve = function(self, completion_item, callback)
  -- client is stopped.
  if self.client.is_stopped() then
    return callback()
  end

  -- client has no completion capability.
  if not self:_get(self.client.server_capabilities, { "completionProvider", "resolveProvider" }) then
    return callback()
  end

  self:_request("completionItem/resolve", completion_item, function(_, response)
    -- print(vim.inspect(response))
    if response and response.documentation then
      response.documentation.value = markdown_format(response.documentation.value)
    end
    -- print(vim.inspect(response))
    callback(response or completion_item)
  end)
end

M.setup = function()
  jdtls.start_or_attach(config)
end

M.init = function()
  vim.g.jdtls_dap_main_class_config_init = true
  -- au BufReadCmd jdt://* lua require('jdtls').open_jdt_link(vim.fn.expand('<amatch>'))
  -- command! JdtWipeDataAndRestart lua require('jdtls.setup').wipe_data_and_restart()
  -- command! JdtShowLogs lua require('jdtls.setup').show_logs()
  vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    pattern = "jdt://*",
    callback = function(e)
      require("jdtls").open_jdt_link(e.file)
    end,
  })
  vim.api.nvim_create_user_command("JdtWipeDataAndRestart", "lua require('jdtls.setup').wipe_data_and_restart()", {})
  vim.api.nvim_create_user_command("JdtShowLogs", "lua require('jdtls.setup').show_logs()", {})

  local group = vim.api.nvim_create_augroup("kide_jdtls_java", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "java" },
    desc = "jdtls",
    callback = function(e)
      -- vim.notify("load: " .. o.buf, vim.log.levels.INFO)
      -- print(vim.inspect(e))
      -- 忽略 telescope 预览的情况
      if e.file == "java" then
        -- ignore
      else
        M.setup()
      end
    end,
  })
  return group
end
return M
