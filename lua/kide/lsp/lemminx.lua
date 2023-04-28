local M = {}
local lemminx_home = os.getenv("LEMMINX_HOME")
if lemminx_home then
  M.setup = function()
    local lspconfig = require("lspconfig")
    local utils = require("kide.core.utils")

    local lemminx_jars = {}
    for _, bundle in ipairs(vim.split(vim.fn.glob(lemminx_home .. "/*.jar"), "\n")) do
      table.insert(lemminx_jars, bundle)
    end
    vim.fn.join(lemminx_jars, utils.is_win and ";" or ":")
    lspconfig["lemminx"].setup({
      cmd = {
        "java",
        "-cp",
        vim.fn.join(lemminx_jars, ":"),
        "org.eclipse.lemminx.XMLServerLauncher",
      },
      on_attach = function(client, buffer)
        require("kide.core.keybindings").maplsp(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, buffer)
        end
      end,
    })
  end
end

return M
