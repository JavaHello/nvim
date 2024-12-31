local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = vim.fs.root(0, { ".stylua.toml", ".git" }) or vim.uv.cwd(),
  on_attach = me.on_attach,
  capabilities = me.capabilities(),
  on_init = me.on_init,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand("$VIMRUNTIME/lua"),
          vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
          vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/luv/library",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
}
return M
