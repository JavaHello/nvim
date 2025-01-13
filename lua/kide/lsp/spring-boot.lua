local M = {}
local me = require("kide.melspconfig")

M.config = require("spring_boot.launch").update_ls_config(require("spring_boot").setup({
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
