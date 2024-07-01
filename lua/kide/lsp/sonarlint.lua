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

    -- https://github.com/SonarSource/sonarlint-vscode/blob/fc8e3f2f6d811dd7d7a7d178f2a471173c233a27/src/lsp/server.ts#L35
    analyzer_jar = vim.tbl_filter(function(value)
      return false
        -- or vim.endswith(value, "sonargo.jar")
        or vim.endswith(value, "sonarjava.jar")
        -- or vim.endswith(value, "sonarjs.jar")
        -- or vim.endswith(value, "sonarphp.jar")
        or vim.endswith(value, "sonarpython.jar")
      -- or vim.endswith(value, "sonarhtml.jar")
      -- or vim.endswith(value, "sonarxml.jar")
      -- or vim.endswith(value, "sonarcfamily.jar")
      -- or vim.endswith(value, "sonartext.jar")
      -- or vim.endswith(value, "sonariac.jar")
      -- or vim.endswith(value, "sonarlintomnisharp.jar")
    end, analyzer_jar)

    local cmd = {
      utils.java_bin(),
      "-Xmx1g",
      "-XX:+UseZGC",
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
        "python",
      },
    }
  end
end
return M
