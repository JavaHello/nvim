local M = {}
M.setup = function(opt)
  if not ("Y" == vim.env["SONARLINT_ENABLE"]) then
    return
  end
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

  local cmd = {
    "java",
    "-jar",
    sonarlint_ls,
    "-stdio",
    "-analyzers",
    analyzer_java,
  }
  require("sonarlint").setup({
    server = {
      cmd = cmd,
    },
    filetypes = {
      "java",
    },
  })
end
return M
