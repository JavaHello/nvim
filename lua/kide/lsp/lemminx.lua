local M = {}
local lemminx_home = vim.env["LEMMINX_HOME"]
if lemminx_home then
  M.setup = function(opt)
    local lspconfig = require("lspconfig")
    local utils = require("kide.core.utils")

    local lemminx_jars = {}
    for _, bundle in ipairs(vim.split(vim.fn.glob(lemminx_home .. "/*.jar"), "\n")) do
      table.insert(lemminx_jars, bundle)
    end
    vim.fn.join(lemminx_jars, utils.is_win and ";" or ":")

    local config = vim.tbl_deep_extend("keep", {
      cmd = {
        "java",
        "-cp",
        vim.fn.join(lemminx_jars, ":"),
        "org.eclipse.lemminx.XMLServerLauncher",
      },
    }, opt)
    lspconfig["lemminx"].setup(config)
  end
end

return M
