local M = {}
M._init_dap = false
function M.init_dap()
  if M._init_dap then
    return
  end
  M._init_dap = true
  local function get_python_path()
    if vim.env.VIRTUAL_ENV then
      return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
    end
    if vim.env.PY_BIN then
      return vim.env.PY_BIN
    end
    local python = vim.fn.exepath("python3")
    if python == nil or python == "" then
      python = vim.fn.exepath("python")
    end
    return python
  end
  require("dap-python").setup(get_python_path())
end

local me = require("kide.melspconfig")
M.config = {
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  root_dir = vim.fs.root(0, { ".git", "requirements.txt", "pyproject.toml" }) or vim.uv.cwd(),
  on_attach = function(client, bufnr)
    local dap_py = require("dap-python")
    vim.keymap.set("n", "<leader>dc", dap_py.test_class, { desc = "Dap Test Class", buffer = bufnr })
    vim.keymap.set("n", "<leader>dm", dap_py.test_method, { desc = "Dap Test Method", buffer = bufnr })
    vim.keymap.set("v", "<leader>ds", dap_py.debug_selection, { desc = "Dap Debug Selection", buffer = bufnr })
    me.on_attach(client, bufnr)
  end,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {
    pyright = {},
  },
}
return M
