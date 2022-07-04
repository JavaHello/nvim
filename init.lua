local present, impatient = pcall(require, "impatient")

if present then
	impatient.enable_profile()
end

require("kide.core.basic")
require("kide.plugins")
vim.defer_fn(function()
	require("kide.lsp")
	require("kide.dap")

	require("kide.core.utils.plantuml").setup()
end, 0)
