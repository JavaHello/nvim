vim.g.sql_type_default = 'mysql'
local M = {}
M.config = {
}
M.on_attach = function(client, bufnr)
  require('sqls').on_attach(client, bufnr)
end
return M;
