local lsp = vim.lsp
local keymap = vim.keymap
local M = {}

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}
local function progress()
  local lsp_group = vim.api.nvim_create_augroup("klsp", {})
  local timer = vim.loop.new_timer()
  vim.api.nvim_create_autocmd("LspProgress", {
    group = lsp_group,
    callback = function()
      if vim.api.nvim_get_mode().mode == "n" then
        vim.cmd.redrawstatus()
      end
      if timer then
        timer:stop()
        timer:start(
          500,
          0,
          vim.schedule_wrap(function()
            timer:stop()
            vim.cmd.redrawstatus()
          end)
        )
      end
    end,
  })
end

M.on_attach = function(client, bufnr)
  local kopts = { noremap = true, silent = true, desc = "Code Action", buffer = bufnr }
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, kopts)
  keymap.set("n", "K", function()
    lsp.buf.hover({ border = "rounded" })
  end, kopts)
  keymap.set("n", "gs", function()
    lsp.buf.signature_help({ border = "rounded" })
  end, kopts)
  keymap.set("n", "gd", lsp.buf.definition, kopts)
  keymap.set("n", "gr", lsp.buf.references, kopts)
  keymap.set("n", "gi", lsp.buf.implementation, kopts)
end

M.on_init = function(client, _)
  if client.supports_method("textDocument/semanticTokens") then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.init_lsp_clients = function()
  progress()
  local capabilities = require("blink.cmp").get_lsp_capabilities(M.capabilities)

  if capabilities.textDocument.foldingRange then
    capabilities.textDocument.foldingRange.dynamicRegistration = false
    capabilities.textDocument.foldingRange.lineFoldingOnly = true
  else
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
  end
  local lspconfig = require("lspconfig")
  lspconfig.lua_ls.setup({
    on_attach = M.on_attach,
    capabilities = capabilities,
    on_init = M.on_init,

    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            vim.fn.expand("$VIMRUNTIME/lua"),
            vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
            vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
            "${3rd}/luv/library",
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  })

  local on_attach = M.on_attach
  local on_init = M.on_init

  -- "ast_grep"
  local servers = { "html", "cssls", "gopls", "zls", "jsonls", "taplo" }
  for _, name in ipairs(servers) do
    lspconfig[name].setup({
      on_attach = on_attach,
      on_init = on_init,
      capabilities = capabilities,
    })
  end

  lspconfig.clangd.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  local metals_enable = vim.env["METALS_ENABLE"]

  if metals_enable == "Y" then
    -- metals
    require("kide.lsp.metals").setup({
      on_attach = on_attach,
      on_init = on_init,
      capabilities = capabilities,
    })
  end

  if vim.env["JDTLS_NVIM_ENABLE"] == "Y" then
    local spring_boot = vim.env["SPRING_BOOT_NVIM_ENABLE"] == "Y"
    local quarkus = vim.env["QUARKUS_NVIM_ENABLE"] == "Y"
    local sonarlint = vim.env["SONARLINT_NVIM_ENABLE"] == "Y"
    require("kide.lsp.java").setup({
      add_bundles = function(bundles)
        if spring_boot then
          vim.list_extend(bundles, require("spring_boot").java_extensions())
        end

        if quarkus then
          vim.list_extend(bundles, require("microprofile").java_extensions())
          vim.list_extend(bundles, require("quarkus").java_extensions())
        end
      end,
      on_attach = on_attach,
      on_init = function(client, ctx)
        on_init(client, ctx)
        if quarkus then
          require("quarkus.bind").try_bind_qute_all_request()
          require("microprofile.bind").try_bind_microprofile_all_request()
        end
      end,
      capabilities = capabilities,
    })
    if spring_boot then
      require("spring_boot").setup({
        server = {
          on_attach = on_attach,
          on_init = function(client, ctx)
            on_init(client, ctx)
            client.server_capabilities.documentHighlightProvider = false
          end,
          capabilities = capabilities,
        },
      })
    end
    if quarkus then
      require("quarkus.launch").setup({
        on_attach = on_attach,
        on_init = function(client, ctx)
          on_init(client, ctx)
          client.server_capabilities.documentHighlightProvider = false
        end,
        capabilities = capabilities,
      })
      require("microprofile.launch").setup({
        on_attach = on_attach,
        on_init = function(client, ctx)
          on_init(client, ctx)
          client.server_capabilities.documentHighlightProvider = false
        end,
        capabilities = capabilities,
      })
    end

    if sonarlint then
      require("kide.lsp.sonarlint").setup()
    end
  end

  -- XML
  require("kide.lsp.lemminx").setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- python
  require("kide.lsp.pyright").setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- SQL
  -- lspconfig.sqls.setup {
  --   cmd = { "sqls", "-config", "~/.config/sqls/config.yml" },
  --   on_attach = on_attach,
  --   on_init = on_init,
  --   capabilities = capabilities,
  -- }

  local util = require("lspconfig.util")
  local function global_node_modules()
    local global_path = ""
    if util.path.exists("/opt/homebrew/") then
      global_path = "/opt/homebrew/lib/node_modules"
    elseif util.path.exists("/usr/local/lib/node_modules") then
      global_path = "/usr/local/lib/node_modules"
    elseif util.path.exists("/usr/lib64/node_modules") then
      global_path = "/usr/lib64/node_modules"
    else
      global_path = util.path.join(os.getenv("HOME"), ".npm", "lib", "node_modules")
    end
    if not util.path.exists(global_path) then
      vim.notify("Global node_modules not found", vim.log.levels.DEBUG)
    end
    return global_path
  end

  local function get_typescript_server_path(root_dir)
    local found_ts = ""
    local function check_dir(path)
      found_ts = util.path.join(path, "node_modules", "typescript", "lib")
      if util.path.exists(found_ts) then
        return path
      end
    end
    if util.search_ancestors(root_dir, check_dir) then
      return found_ts
    else
      local global_ts = util.path.join(global_node_modules(), "typescript", "lib")
      return global_ts
    end
  end

  -- 需要安装 Vue LSP 插件
  -- npm install -g @vue/language-server
  -- npm install -g @vue/typescript-plugin
  require("lspconfig").volar.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    on_new_config = function(new_config, new_root_dir)
      new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
    end,
  })

  require("lspconfig").ts_ls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = util.path.join(global_node_modules(), "@vue", "typescript-plugin"),
          languages = { "javascript", "typescript", "vue" },
        },
      },
    },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "vue",
    },
  })
end

return M
