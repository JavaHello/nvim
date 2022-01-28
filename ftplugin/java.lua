local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- local workspace_dir = '/Users/kailuo/jdtls-workspace/' .. project_name
local workspace_dir = '/Users/kailuo/jdtls-workspace/'

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
    '-Xms1g',
    '-Xmx1g',
    "-javaagent:/opt/software/lsp/lombok.jar",
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', '/opt/software/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
    '-configuration', '/opt/software/jdtls/config_mac',
    '-data', workspace_dir,
  },

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
          userSettings = "/Users/kailuo/workspace/paylabs/maven/settings.xml",
          globalSettings = "/Users/kailuo/workspace/paylabs/maven/settings.xml",
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
  init_options = {
    bundles = {},
    workspace = workspace_dir
  },
}
local jdtls = require('jdtls')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
config.capabilities = capabilities;
jdtls.start_or_attach(config)

local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true }

map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
-- rename
map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opt)
-- code action
map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opt)
-- go xx
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opt)
map('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opt)
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opt)
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opt)
-- diagnostic
map('n', 'go', '<cmd>lua vim.diagnostic.open_float()<CR>', opt)
map('n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opt)
map('n', ']g', '<cmd>lua vim.diagnostic.goto_next()<CR>', opt)
-- map('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
-- leader + =
map('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opt)

