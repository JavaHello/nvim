local M = {}
local env = {
  HOME = vim.loop.os_homedir(),
  JAVA_HOME = vim.env["JAVA_HOME"],
  JDTLS_RUN_JAVA = vim.env["JDTLS_RUN_JAVA"],
  JDTLS_HOME = vim.env["JDTLS_HOME"],
  JDTLS_WORKSPACE = vim.env["JDTLS_WORKSPACE"],
  LOMBOK_JAR = vim.env["LOMBOK_JAR"],
  JOL_JAR = vim.env["JOL_JAR"],
}
local maven = require("kide.core.utils.maven")

local function or_default(a, v)
  return require("kide.core.utils").or_default(a, v)
end

local function get_java_home()
  return or_default(env.JAVA_HOME, "/opt/software/java/zulu17.34.19-ca-jdk17.0.3-macosx_aarch64")
end
local function get_java_ver_home(v, dv)
  return vim.env["JAVA_" .. v .. "_HOME"] or dv
end
local function get_java_ver_sources(v, dv)
  return vim.env["JAVA_" .. v .. "_SOURCES"] or dv
end

local function get_jdtls_workspace()
  return or_default(env.JDTLS_WORKSPACE, env.HOME .. "/jdtls-workspace/")
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
      if ExecutionEnvironment.JavaSE_1_8 == value then
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
    vim.notify("Please config Java runtimes (JAVA_8_HOME...)")
  end
  return result
end)()

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_dir = get_jdtls_workspace() .. project_name
-- local jdtls_path = vscode.find_one("/redhat.java-*/server")
local function get_jdtls_path()
  return or_default(env.JDTLS_HOME, vscode.find_one("/redhat.java-*/server"))
end

local function jdtls_launcher()
  local jdtls_path = get_jdtls_path()
  if jdtls_path then
    jdtls_path = vim.fn.glob(jdtls_path .. "/bin/jdtls")
  elseif require("mason-registry").has_package("jdtls") then
    jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path() .. "/bin/jdtls"
  end
  if not jdtls_path then
    vim.notify("jdtls_path is empty", vim.log.levels.ERROR)
    return
  end
  local cmd = {
    jdtls_path,
    "--jvm-arg=-Dlog.protocol=true",
    "--jvm-arg=-Dlog.level=ALL",
    "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
    "--jvm-arg=" .. "-XX:+UseZGC",
    "--jvm-arg=" .. "-Xmx1g",
  }
  if env.LOMBOK_JAR then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. env.LOMBOK_JAR)
  end
  table.insert(cmd, "-data=" .. workspace_dir)
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

local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })

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
      maxConcurrentBuilds = 8,
      home = get_java_home(),
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
      autobuild = { enabled = true },
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

config["on_attach"] = function(client, buffer)
  -- client.server_capabilities.semanticTokensProvider = nil
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
  require("java-deps").attach(client, buffer, root_dir)
  create_command(buffer, "JavaProjects", require("java-deps").toggle_outline, {
    nargs = 0,
  })
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

vim.lsp.handlers["$/progress"] = nil
require("fidget").setup({})

local function markdown_format(input)
  if input then
    -- input = string.gsub(input, "[\r\n]( +)(%*)", function (i1)
    --   return i1 .. "-"
    -- end)
    input = string.gsub(input, "%[([%a%$_]?[%.%w%(%),\\_%[%]%s ]*)%]%(file:/[^%)]+%)", function(i1)
      return "`" .. i1 .. "`"
    end)
    input = string.gsub(input, "%[([%a%$_]?[%.%w%(%),\\_%[%]%s ]*)%]%(jdt://[^%)]+%)", function(i1)
      return "`" .. i1 .. "`"
    end)
  end
  return input
end

local function split_lines(value)
  value = string.gsub(value, "\r\n?", "\n")
  return vim.split(value, "\n", { plain = true })
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

M.start = function()
  jdtls.start_or_attach(config)
end

M.setup = function()
  vim.g.jdtls_dap_main_class_config_init = true
  -- au BufReadCmd jdt://* lua require('jdtls').open_jdt_link(vim.fn.expand('<amatch>'))
  -- command! JdtWipeDataAndRestart lua require('jdtls.setup').wipe_data_and_restart()
  -- command! JdtShowLogs lua require('jdtls.setup').show_logs()
  vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    pattern = "jdt://*",
    callback = function(e)
      require("jdtls").open_classfile(e.file)
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
      if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
        -- ignore
      else
        M.start()
      end
    end,
  })
  return group
end
return M
