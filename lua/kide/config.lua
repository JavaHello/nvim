local M = {
  env = {
    py_bin = vim.env["PY_BIN"] or "/usr/bin/python3",
  },
  plugin = {
    copilot = {
      enable = vim.env["COPILOT_ENABLE"] == "Y" and true or false,
    },
  },
}
return M
