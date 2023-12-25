local M = {}
M.setup = function(opt)
  local vscode = require("kide.core.vscode")
  local sonarlint_ls = vscode.find_one("/sonarsource.sonarlint-vscode*/server/sonarlint-ls.jar")
  local analyzer_java = vscode.find_one("/sonarsource.sonarlint-vscode*/analyzers/sonarjava.jar")
  if not sonarlint_ls then
    vim.notify("sonarlint-ls.jar not found", vim.log.levels.WARN)
    return
  end
  if not analyzer_java then
    vim.notify("sonarjava.jar not found", vim.log.levels.WARN)
    return
  end

  local lombok_jar = vscode.get_lombok_jar()
  local cmd = {
    "java",
    "-jar",
    sonarlint_ls,
    "-stdio",
    "-analyzers",
    analyzer_java,
  }
  if lombok_jar ~= nil then
    table.insert(cmd, "-Dsonar.java.libraries=" .. lombok_jar)
  end
  require("sonarlint").setup({
    server = {
      cmd = {
        "java",
        "-jar",
        sonarlint_ls,
        "-stdio",
        "-analyzers",
        analyzer_java,
      },
    },
    filetypes = {
      "java",
    },
  })
end
return M
