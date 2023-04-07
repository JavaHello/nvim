vim.g.sql_type_default = "mysql"
return {
  server = {
    on_attach = function(client, bufnr)
      require("sqls").on_attach(client, bufnr)
    end,
  },
}
