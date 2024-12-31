local M = {}
local me = require("kide.melspconfig")
require("spring_boot.launch").update_config({
  server = {
    on_attach = me.on_attach,
    on_init = function(client, ctx)
      client.server_capabilities.documentHighlightProvider = false
      me.on_init(client, ctx)
    end,
    capabilities = me.capabilities(),
  },
})
M.config = require("spring_boot.launch").ls_config

return M
