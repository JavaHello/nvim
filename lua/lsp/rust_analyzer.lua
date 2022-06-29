-- Update this path
local extension_path = "/Users/kailuo/.vscode/extensions/vadimcn.vscode-lldb-1.7.0/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

return {
	dap = { adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path) },
	server = {
		standalone = false,
		settings = {
			["rust-analyzer"] = {
				completion = {
					postfix = {
						enable = false,
					},
				},
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	},
}
