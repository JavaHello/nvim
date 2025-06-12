local M = {}
local me = require("kide.melspconfig")
local function ls_path()
  local path = vim.env["JDTLS_SPRING_TOOLS_PATH"]
  if path == nil or path == "" then
    return nil
  end
  return require("spring_boot").get_boot_ls(path .. "/language-server")
end
local lspath = ls_path()
if lspath == nil then
  return M
end
M.config = require("spring_boot.launch").update_ls_config(require("spring_boot").setup({
  ls_path = lspath,
  server = {
    on_attach = me.on_attach,
    on_init = function(client, ctx)
      client.server_capabilities.documentHighlightProvider = false
      me.on_init(client, ctx)
    end,
    capabilities = me.capabilities(),
  },
  autocmd = false,
}))

return M
