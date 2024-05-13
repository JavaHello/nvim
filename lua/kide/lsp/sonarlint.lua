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

    analyzer_jar = vim.tbl_filter(function(value)
      return vim.endswith(value, "sonarjava.jar")
    end, analyzer_jar)

    local cmd = {
      utils.java_bin(),
      "-Dsonarlint.telemetry.disabled=true",
      "-jar",
      sonarlint_ls,
      "-stdio",
      "-analyzers",
    }
    vim.list_extend(cmd, analyzer_jar)
    require("sonarlint").setup {
      server = {
        cmd = cmd,
        settings = {
          sonarlint = {
            disableTelemetry = true,
          },
        },
      },
      filetypes = {
        "java",
      },
    }
  end
end
return M
