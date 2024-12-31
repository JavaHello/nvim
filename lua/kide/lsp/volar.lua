local M = {}
local me = require("kide.melspconfig")
local vfn = vim.fn
local function get_typescript_server_path(root_dir)
  local found_ts = vim.fs.joinpath(root_dir, "node_modules", "typescript", "lib")
  if vfn.isdirectory(found_ts) == 1 then
    return found_ts
  end
  return vim.fs.joinpath(me.global_node_modules(), "typescript", "lib")
end

-- 需要安装 Vue LSP 插件
-- npm install -g @vue/language-server
-- npm install -g @vue/typescript-plugin
M.config = {
  name = "volar",
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_dir = vim.fs.root(0, { "package.json" }),
  init_options = {
    typescript = {
      tsdk = "",
    },
  },
  on_attach = me.on_attach,
  on_init = me.on_init,
  capabilities = me.capabilities(),
  settings = {
    volar = {},
  },
  on_new_config = function(new_config, new_root_dir)
    if
      new_config.init_options
      and new_config.init_options.typescript
      and new_config.init_options.typescript.tsdk == ""
    then
      new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
    end
  end,
}
return M
