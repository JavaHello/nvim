local M = {}
local me = require("kide.melspconfig")

-- jar 查找交给插件: $LEMMINX_HOME 下的 uber jar 作为 LemMinX, 其余 jar 作为 lemminx-maven 扩展
M.setup = function()
  require("lemminx_maven").setup({
    server = {
      on_attach = me.on_attach,
      on_init = me.on_init,
      capabilities = me.capabilities(),
    },
  })
end

return M
