local M = {}
M.setup = function(opts)
  local config = {
    server = opts,
  }

  local ok, spring_boot = pcall(require, "spring_boot")
  if ok then
    spring_boot.setup(config)
  end
end
return M
