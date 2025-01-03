local M = {}

local me = require("kide.melspconfig")
local function reload_workspace(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust-analyzer" })
  for _, client in ipairs(clients) do
    vim.notify("Reloading Cargo Workspace")
    client:request("rust-analyzer/reloadWorkspace", nil, function(err)
      if err then
        error(tostring(err))
      end
      vim.notify("Cargo workspace reloaded")
    end, 0)
  end
end

M.config = {
  name = "rust-analyzer",
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  single_file_support = true,
  init_options = {
    provideFormatter = true,
  },
  root_dir = vim.fs.root(0, { ".git", "Cargo.toml" }),
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities({
    experimental = {
      serverStatusNotification = true,
    },
  }),
}
return M
