local M = {
  env = {
    py_bin = vim.env["PY_BIN"] or "/usr/bin/python3",
    flutter_home = vim.env["FLUTTER_HOME"] or "/opt/software/flutter",
  },
  plugin = {
    copilot = {
      enable = vim.env["COPILOT_ENABLE"] == "Y" and true or false,
    },
  },
}
return M
