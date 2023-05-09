local M = {
  env = {
    py_bin = os.getenv("PY_BIN") or "/usr/bin/python3",
  },
  plugin = {
    copilot = {
      enable = os.getenv("COPILOT_ENABLE") or false,
    },
  },
}
return M
