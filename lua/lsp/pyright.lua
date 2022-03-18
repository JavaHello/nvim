local M = {}
M.config = {
}
M.on_attach = function (_, _)
  -- vim.cmd[[
  --   command! -nargs=0 OR   :lua require'nvim-lsp-installer.extras.pyright'.organize_imports()
  -- ]]
end
return M;
