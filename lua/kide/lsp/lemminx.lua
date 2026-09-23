local M = {}
local lemminx_home = vim.env["LEMMINX_HOME"]

if lemminx_home then
  local utils = require("kide.tools")
  local me = require("kide.melspconfig")
  local lemminx_jars = vim.split(vim.fn.glob(vim.fs.joinpath(lemminx_home, "*.jar")), "\n")
  M.config = {
    name = "lemminx",
    cmd = {
      utils.java_bin(),
      "-cp",
      -- 类路径分隔符: Windows 是分号, 其余是冒号
      vim.fn.join(lemminx_jars, utils.is_win and ";" or ":"),
      "org.eclipse.lemminx.XMLServerLauncher",
    },
    settings = {
      lemminx = {},
    },
    filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
    root_dir = vim.fs.root(0, { ".git" }) or vim.uv.cwd(),
    single_file_support = true,
    on_attach = me.on_attach,
    on_init = me.on_init,
    capabilities = me.capabilities(),
  }
end

return M
