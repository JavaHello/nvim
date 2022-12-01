local codelldb = require("kide.dap.codelldb")
local adapter = function()
  if codelldb.extension_path then
    return require("rust-tools.dap").get_codelldb_adapter(codelldb.codelldb_path, codelldb.liblldb_path)
  end
end
local rt = require("rust-tools")
return {
  dap = {
    adapter = adapter(),
  },
  tools = {
    inlay_hints = {
      parameter_hints_prefix = " ",
      other_hints_prefix = " ",
    },
  },
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<Leader>ha", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
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
