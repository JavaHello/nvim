local M = {}
M.config = {}

M.organize_imports = function()
	local params = {
		command = "pyright.organizeimports",
		arguments = { vim.uri_from_bufnr(0) },
	}
	vim.lsp.buf.execute_command(params)
end

M.on_attach = function(_, _)
	vim.cmd([[
    command! -nargs=0 OR   :lua require'lsp.pyright'.organize_imports()
  ]])
end
return M
