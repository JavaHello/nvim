local M = {}

local lspconfig = require "lspconfig"
M.setup = function(opts)
  local on_attach = opts.on_attach
  local config = vim.tbl_deep_extend("keep", {
    on_attach = function(client, bufnr)
      local dap_py = require "dap-python"
      vim.keymap.set("n", "<leader>dc", dap_py.test_class, { desc = "Dap Test Class" })
      vim.keymap.set("n", "<leader>dm", dap_py.test_method, { desc = "Dap Test Method" })
      vim.keymap.set("v", "<leader>ds", dap_py.debug_selection, { desc = "Dap Debug Selection" })
      on_attach(client, bufnr)
    end,
  }, opts)
  lspconfig.pyright.setup(config)
end
return M
