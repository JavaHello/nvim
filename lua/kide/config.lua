local M = {
  env = {
    py_bin = os.getenv("py_bin") or "/usr/bin/python3",
  },
  plugin = {
    copilot = {
      enable = os.getenv("copilot_enable") or false,
    },
  },
}
return M
