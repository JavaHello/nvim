local M = {}

vim.g.enable_spring_boot = vim.env["NVIM_SPRING_BOOT"] == "Y"
vim.g.enable_quarkus = vim.env["NVIM_QUARKUS"] == "Y"

return M
