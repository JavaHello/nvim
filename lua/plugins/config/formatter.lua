local prettierConfig = function()
  return {
    exe = "prettier",
    args = { "--stdin-filepath", vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), "--single-quote" },
    stdin = true
  }
end

require("formatter").setup(
  {
    filetype = {
      -- lua = {function() return {exe = "lua-format", stdin = true} end},
      json = { prettierConfig },
      html = { prettierConfig },
      javascript = { prettierConfig },
      typescript = { prettierConfig },
      typescriptreact = { prettierConfig },
      markdown = { prettierConfig },
      sql = { function()
        return {
          exe = "sql-formatter",
          args = { vim.fn.shellescape(vim.api.nvim_buf_get_name(0)) },
          stdin = true,
        }
      end }
    }
  }
)
