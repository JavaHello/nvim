return {
	server = {
		organize_imports = function()
			local params = {
				command = "pyright.organizeimports",
				arguments = { vim.uri_from_bufnr(0) },
			}
			vim.lsp.buf.execute_command(params)
		end,
		on_attach = function(_, _)
			vim.cmd([[
    command! -nargs=0 OR   :lua require'lsp.pyright'.organize_imports()
  ]])
		end,
	},
}
