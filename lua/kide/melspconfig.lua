local lsp = vim.lsp
local keymap = vim.keymap
local vfn = vim.fn
local M = {}
local kide = require("kide")

function notify_progress()
  ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
  local progress = vim.defaulttable()
  vim.api.nvim_create_autocmd("LspProgress", {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value
      if not client or type(value) ~= "table" then
        return
      end
      kide.lsp_stl("[" .. client.name .. "] " .. (value.message or ""))
    end,
  })
end

M.on_attach = function(client, bufnr)
  if vim.lsp.document_color then
    vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })
  end
  local kopts = { noremap = true, silent = true, buffer = bufnr }
  keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, kopts)
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
  vim.keymap.set("n", "]r", function()
    Snacks.words.jump(1)
  end, kopts)
  vim.keymap.set("n", "[r", function()
    Snacks.words.jump(-1)
  end, kopts)
end

M.on_init = function(client, _)
  -- 由于卡顿，暂时禁用semanticTokens
  -- 看起来已经修复了，可以试试
  -- if client.supports_method("textDocument/semanticTokens") then
  --   client.server_capabilities.semanticTokensProvider = nil
  -- end
end
M.capabilities = function(opt)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if opt then
    capabilities = vim.tbl_deep_extend("force", capabilities, opt)
  end

  return require("blink.cmp").get_lsp_capabilities(capabilities)
end

M.init_lsp_progress = function()
  notify_progress()
end

function M.global_node_modules()
  local global_path = ""
  if vfn.isdirectory("/opt/homebrew/lib/node_modules") == 1 then
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
