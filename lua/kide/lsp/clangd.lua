local M = {}
local has_clangd = vim.fn.executable("clangd") == 1
local me = require("kide.melspconfig")

local root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.txt",
  "configure.ac", -- AutoTools
  ".git",
}

M.start = function()
  if has_clangd then
    -- root_dir 需按当前 buffer 计算，不能在模块加载时固定
    M.config.root_dir = vim.fs.root(0, root_markers) or vim.uv.cwd()
    vim.lsp.start(M.config)
  end
end

M.config = {
  name = "clangd",
  cmd = { "clangd" },
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
