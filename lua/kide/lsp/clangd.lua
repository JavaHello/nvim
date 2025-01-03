local M = {}

local me = require("kide.melspconfig")
M.config = {
  name = "clangd",
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = vim.fs.root(0, {
    ".git",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
  }) or vim.uv.cwd(),
  single_file_support = true,
  capabilities = me.capabilities({
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  }),
  on_attach = function(client, bufnr)
    local create_command = vim.api.nvim_buf_create_user_command
    create_command(bufnr, "DapConfigGdb", me.dap_gdb, {
      nargs = 0,
    })
    me.on_attach(client, bufnr)
  end,
  on_init = me.on_init,
}

return M
