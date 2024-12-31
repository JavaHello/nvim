local M = {}
local lemminx_home = vim.env["LEMMINX_HOME"]

if lemminx_home then
  local utils = require("kide.tools")
  local me = require("kide.melspconfig")
  local lemminx_jars = {}
  for _, bundle in ipairs(vim.split(vim.fn.glob(lemminx_home .. "/*.jar"), "\n")) do
    table.insert(lemminx_jars, bundle)
  end
  vim.fn.join(lemminx_jars, utils.is_win and ";" or ":")
  M.config = {
    name = "lemminx",
    cmd = {
      utils.java_bin(),
      "-cp",
      vim.fn.join(lemminx_jars, ":"),
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
