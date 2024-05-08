local M = {}

M.setup = function()
  if "Y" == vim.env["SONARLINT_ENABLE"] then
    local vscode = require "kide.core.vscode"
    local utils = require "kide.core.utils"
    local sonarlint_ls = vscode.find_one "/sonarsource.sonarlint-vscode*/server/sonarlint-ls.jar"
    if not sonarlint_ls then
      vim.notify("sonarlint not found", vim.log.levels.WARN)
      return
    end
    local analyzer_path = vscode.find_one "/sonarsource.sonarlint-vscode*/analyzers"

    local analyzer_jar = vim.split(vim.fn.glob(analyzer_path .. "/*.jar"), "\n")

    local cmd = {
      utils.java_bin(),
      "-jar",
      sonarlint_ls,
      "-stdio",
      "-analyzers",
    }
    vim.list_extend(cmd, analyzer_jar)
    require("sonarlint").setup {
      server = {
        cmd = cmd,
      },
      filetypes = {
        "java",
      },
    }
  end
end
return M
