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
  on_attach = me.on_attach,
  on_init = me.on_init,
}

return M
