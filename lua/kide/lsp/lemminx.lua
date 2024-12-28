local M = {}
local lemminx_home = vim.env["LEMMINX_HOME"]

M.setup = function(opt)
  if lemminx_home then
    local lspconfig = require("lspconfig")
    local utils = require("kide.tools")

    local lemminx_jars = {}
    for _, bundle in ipairs(vim.split(vim.fn.glob(lemminx_home .. "/*.jar"), "\n")) do
      table.insert(lemminx_jars, bundle)
    end
    vim.fn.join(lemminx_jars, utils.is_win and ";" or ":")

    local config = vim.tbl_deep_extend("keep", {
      cmd = {
        utils.java_bin(),
        "-cp",
        vim.fn.join(lemminx_jars, ":"),
        "org.eclipse.lemminx.XMLServerLauncher",
      },
    }, opt)
    lspconfig["lemminx"].setup(config)
  end
end

return M
