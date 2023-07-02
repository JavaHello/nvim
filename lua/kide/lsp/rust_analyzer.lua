local M = {}
local codelldb = require("kide.dap.codelldb")
local adapter = function()
  if codelldb.extension_path then
    return require("rust-tools.dap").get_codelldb_adapter(codelldb.codelldb_path, codelldb.liblldb_path)
  end
end
local config = {
  dap = {
    adapter = adapter(),
  },
  tools = {
    inlay_hints = {
      auto = false,
      parameter_hints_prefix = " ",
      other_hints_prefix = " ",
    },
  },
  server = {
    standalone = false,
    settings = {
      ["rust-analyzer"] = {
        completion = {
          postfix = {
            enable = false,
          },
        },
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
}
M.setup = function(opt)
  local rt = require("rust-tools")
  local on_attach = opt.on_attach
  config.server = vim.tbl_deep_extend("keep", config.server, opt)
  config.server.on_attach = function(client, bufnr)
    if on_attach then
      on_attach(client, bufnr)
    end
    -- Hover actions
    vim.keymap.set("n", "<Leader>ha", rt.hover_actions.hover_actions, { buffer = bufnr })
    -- Code action groups
    vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
  end
  rt.setup(config)
end

return M
