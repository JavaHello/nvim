return {
  server = {
    on_attach = function(_, bufnr)
      local dap_py = require("dap-python")
      local opts = { silent = true, buffer = bufnr }
      vim.keymap.set("n", "<leader>dc", dap_py.test_class, opts)
      vim.keymap.set("n", "<leader>dm", dap_py.test_method, opts)
      vim.keymap.set("v", "<leader>ds", dap_py.debug_selection, opts)
    end,
  },
}
