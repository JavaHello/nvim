local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  vim.notify(install_path, vim.log.levels.INFO)
  packer_bootstrap = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end
return packer_bootstrap
