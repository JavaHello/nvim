local lemminx_home = vim.env["LEMMINX_HOME"]

if lemminx_home then
  vim.lsp.start(require("kide.lsp.lemminx").config)
end
