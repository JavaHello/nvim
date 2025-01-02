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

-- see nvim-lspconfig
function M.organize_imports()
  local params = {
    command = "pyright.organizeimports",
    arguments = { vim.uri_from_bufnr(0) },
  }

  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "pyright",
  })
  for _, client in ipairs(clients) do
    client:request("workspace/executeCommand", params, nil, 0)
  end
end

M.config = {
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  root_dir = vim.fs.root(0, { ".git", "requirements.txt", "pyproject.toml" }) or vim.uv.cwd(),
  on_attach = function(client, bufnr)
    local dap_py = require("dap-python")
    vim.keymap.set("n", "<leader>dc", dap_py.test_class, { desc = "Dap Test Class", buffer = bufnr })
    vim.keymap.set("n", "<leader>dm", dap_py.test_method, { desc = "Dap Test Method", buffer = bufnr })
    vim.keymap.set("v", "<leader>ds", dap_py.debug_selection, { desc = "Dap Debug Selection", buffer = bufnr })

    local create_command = vim.api.nvim_buf_create_user_command
    create_command(bufnr, "OR", M.organize_imports, {
      nargs = 0,
    })
    me.on_attach(client, bufnr)
  end,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}

return M
