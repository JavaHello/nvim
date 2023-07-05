local M = {
  env = {
    py_bin = vim.env["PY_BIN"] or "/usr/bin/python3",
    rime_ls_bin = vim.env["RIME_LS_BIN"],
  },
  plugin = {
    copilot = {
      enable = vim.env["COPILOT_ENABLE"] == "Y" and true or false,
    },
  },
}
return M
