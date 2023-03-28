local M = {
  plugin = {
    copilot = {
      enable = os.getenv("copilot_enable") or false,
    },
  },
}
return M
