local present, impatient = pcall(require, "impatient")

if present then
	impatient.enable_profile()
end

require("core.basic")
require("plugins")
vim.defer_fn(function()
	require("lsp")
	require("dap-cfg")

	require("core.utils.plantuml").setup()
end, 0)
