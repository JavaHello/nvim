local env = {
  -- HOME = vim.loop.os_homedir(),
  MAVEN_SETTINGS = os.getenv 'MAVEN_SETTINGS',
}

local maven_settings = '/opt/software/apache-maven-3.6.3/conf/settings.xml'
local function get_maven_settings()
  return env.MAVEN_SETTINGS and env.MAVEN_SETTINGS or maven_settings 
end



local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- local workspace_dir = '/Users/kailuo/jdtls-workspace/' .. project_name
local workspace_dir = '/Users/kailuo/jdtls-workspace/' .. project_name

local jdtls_launcher = vim.fn.glob("/opt/software/lsp/jdtls/plugins/org.eclipse.equinox.launcher_*.jar");
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    '/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home/bin/java', -- or '/path/to/java11_or_newer/bin/java'
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-XX:+UseParallelGC',
    '-XX:GCTimeRatio=4',
    '-XX:AdaptiveSizePolicyWeight=90',
    '-Dsun.zip.disableMemoryMapping=true',
    '-Xms100m',
    '-Xmx2g',
    '-javaagent:/opt/software/lsp/lombok.jar',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', jdtls_launcher,
    '-configuration', '/opt/software/lsp/jdtls/config_mac',
    '-data', workspace_dir,
  },
  filetypes = {"java"},

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      home = "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home",
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
            path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home",
          },
          {
            name = "JavaSE-11",
            path = "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home",
          },
          {
            name = "JavaSE-17",
            path = "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home",
          },
        }
      },
    }
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


-- This bundles definition is the same as in the previous section (java-debug installation)
local bundles = {
  vim.fn.glob("/opt/software/lsp/java/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
};

-- /opt/software/lsp/java/vscode-java-test/server
vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-test/server/*.jar"), "\n"));

-- /opt/software/lsp/java/vscode-java-dependency/jdtls.ext/
-- vim.list_extend(bundles, vim.split(vim.fn.glob("/opt/software/lsp/java/vscode-java-dependency/jdtls.ext/com.microsoft.jdtls.ext.core/target/com.microsoft.jdtls.ext.core-*.jar"), "\n"));
config['init_options'] = {
  bundles = bundles;
}

config['on_attach'] = function(client, bufnr)
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  require('jdtls.setup').add_commands();
  -- require('jdtls.dap').setup_dap_main_class_configs({ verbose = true })
end


local jdtls = require('jdtls')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- capabilities.experimental = {
--   hoverActions = true,
--   hoverRange = true,
--   serverStatusNotification = true,
--   snippetTextEdit = true,
--   codeActionGroup = true,
--   ssr = true,
-- }

config.capabilities = capabilities;
jdtls.start_or_attach(config)

local map = vim.api.nvim_set_keymap
require('keybindings').maplsp(map)

vim.cmd([[
command! -nargs=0 OR   :lua require'jdtls'.organize_imports()
command! -nargs=0 Format  :lua vim.lsp.buf.formatting()
nnoremap crv <Cmd>lua require('jdtls').extract_variable()<CR>
vnoremap crv <Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>
nnoremap crc <Cmd>lua require('jdtls').extract_constant()<CR>
vnoremap crc <Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>
vnoremap crm <Esc><Cmd>lua require('jdtls').extract_method(true)<CR>


function! s:jdtls_test_class_ui()
  lua require'jdtls'.test_class()
  lua require'dapui'.open()
endfunction
function! s:jdtls_test_method_ui()
  lua require'jdtls'.test_nearest_method()
  lua require'dapui'.open()
endfunction
command! -nargs=0 TestClass  :lua require'jdtls'.test_class()
command! -nargs=0 TestMethod  :lua require'jdtls'.test_nearest_method()
command! -nargs=0 TestClassUI  :call s:jdtls_test_class_ui()
command! -nargs=0 TestMethodUI :call s:jdtls_test_method_ui()
nnoremap <leader>dc <Cmd>lua require'jdtls'.test_class()<CR>
nnoremap <leader>dm <Cmd>lua require'jdtls'.test_nearest_method()<CR>


" command! -nargs=0 JdtRefreshDebugConfigs :lua require('jdtls.dap').setup_dap_main_class_configs()
"
" command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)
" command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)
" command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()
" command! -buffer JdtJol lua require('jdtls').jol()
" command! -buffer JdtBytecode lua require('jdtls').javap()
" command! -buffer JdtJshell lua require('jdtls').jshell()

" nnoremap <silent> <space>p <cmd>call lighttree#plugin#jdt#toggle_win()<cr>
]])

