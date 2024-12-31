local lsp = vim.lsp
local keymap = vim.keymap
local vfn = vim.fn
local M = {}

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
  local kopts = { noremap = true, silent = true, buffer = bufnr }
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, kopts)
  keymap.set("n", "K", function()
    lsp.buf.hover({ border = "rounded" })
  end, kopts)
  keymap.set("n", "gs", function()
    lsp.buf.signature_help({ border = "rounded" })
  end, kopts)
  keymap.set("n", "gd", lsp.buf.definition, kopts)
  keymap.set("n", "gD", lsp.buf.type_definition, kopts)
  keymap.set("n", "gr", lsp.buf.references, kopts)
  keymap.set("n", "gi", lsp.buf.implementation, kopts)
  keymap.set("n", "<leader>rn", lsp.buf.rename, kopts)
end

M.on_init = function(client, _)
  if client.supports_method("textDocument/semanticTokens") then
    client.server_capabilities.semanticTokensProvider = nil
  end
end
M.capabilities = function(opt)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem = {
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
  if opt then
    capabilities = vim.tbl_deep_extend("force", capabilities, opt)
  end

  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
  if capabilities.textDocument.foldingRange then
    capabilities.textDocument.foldingRange.dynamicRegistration = false
    capabilities.textDocument.foldingRange.lineFoldingOnly = true
  else
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
  end
  return capabilities
end

M.init_lsp_progress = function()
  progress()
end

function M.global_node_modules()
  local global_path = ""
  if vfn.isdirectory("/opt/homebrew/") == 1 then
    global_path = "/opt/homebrew/lib/node_modules"
  elseif vfn.isdirectory("/usr/local/lib/node_modules") == 1 then
    global_path = "/usr/local/lib/node_modules"
  elseif vfn.isdirectory("/usr/lib64/node_modules") == 1 then
    global_path = "/usr/lib64/node_modules"
  else
    global_path = vim.fs.joinpath(os.getenv("HOME"), ".npm", "lib", "node_modules")
  end
  if vfn.isdirectory(global_path) == 0 then
    vim.notify("Global node_modules not found", vim.log.levels.DEBUG)
  end
  return global_path
end

return M
