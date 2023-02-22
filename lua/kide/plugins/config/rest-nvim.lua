require("rest-nvim").setup({
  -- Open request results in a horizontal split
  result_split_horizontal = false,
  -- Skip SSL verification, useful for unknown certificates
  skip_ssl_verification = false,
  -- Highlight request on run
  highlight = {
    enabled = true,
    timeout = 150,
  },
  result = {
    -- toggle showing URL, HTTP info, headers at top the of result window
    show_url = true,
    show_http_info = true,
    show_headers = true,
  },
  -- Jump to request line on run
  jump_to_request = false,
  env_file = ".env",
  custom_dynamic_variables = {},
  yank_dry_run = true,
})
local group = vim.api.nvim_create_augroup("kide_jdtls_rest_http", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = { "http" },
  callback = function(o)
    vim.api.nvim_buf_create_user_command(o.buf, "Http", ":lua require'rest-nvim'.run()", { nargs = 0 })
    vim.api.nvim_buf_create_user_command(o.buf, "HttpCurl", ":lua require'rest-nvim'.run(true)", { nargs = 0 })
    vim.api.nvim_buf_create_user_command(o.buf, "HttpLast", ":lua require'rest-nvim'.last()", { nargs = 0 })
  end,
})
