local vscode = require("kide.core.vscode")
local utils = require("kide.core.utils")
-- Update this path
local extension_path = vscode.find_one("/vadimcn.vscode-lldb-*")
local codelldb_path = (function()
  if not extension_path then
    return nil
  end
  if utils.is_win then
    return extension_path .. "adapter\\codelldb.exe"
  else
    return extension_path .. "adapter/codelldb"
  end
end)()
local liblldb_path = (function()
  if not extension_path then
    return nil
  end
  if utils.is_mac then
    return extension_path .. "lldb/lib/liblldb.dylib"
  elseif utils.is_win then
    return extension_path .. "lldb\\lib\\liblldb.dll"
  else
    return extension_path .. "lldb/lib/liblldb.so"
  end
end)()

local adapter = function()
  if codelldb_path and liblldb_path then
    print(codelldb_path)
    return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
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
