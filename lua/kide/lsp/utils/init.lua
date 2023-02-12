local M = {}

M.format_range_operator = function()
  local old_func = vim.go.operatorfunc
  _G.op_func_formatting = function()
    local start = vim.api.nvim_buf_get_mark(0, "[")
    local finish = vim.api.nvim_buf_get_mark(0, "]")

    local bfn = vim.api.nvim_get_current_buf()
    vim.lsp.buf.format({
      bufnr = bfn,
      filter = function(c)
        return require("kide.lsp.utils").filter_format_lsp_client(c, bfn)
      end,
      range = {
        start,
        finish,
      },
    })
    vim.go.operatorfunc = old_func
    _G.op_func_formatting = nil
  end
  vim.go.operatorfunc = "v:lua.op_func_formatting"
  vim.api.nvim_feedkeys("g@", "n", false)
end

-- 指定格式化 lsp_client
local format_lsp_mapping = {}
format_lsp_mapping["java"] = "jdtls"

-- sql_formatter
format_lsp_mapping["sql"] = "null-ls"
format_lsp_mapping["mysql"] = "null-ls"
-- prettier
format_lsp_mapping["javascript"] = "null-ls"
format_lsp_mapping["javascriptreact"] = "null-ls"
format_lsp_mapping["typescript"] = "null-ls"
format_lsp_mapping["typescriptreact"] = "null-ls"
format_lsp_mapping["vue"] = "null-ls"
format_lsp_mapping["css"] = "null-ls"
format_lsp_mapping["scss"] = "null-ls"
format_lsp_mapping["less"] = "null-ls"
format_lsp_mapping["html"] = "null-ls"
format_lsp_mapping["json"] = "null-ls"
format_lsp_mapping["jsonc"] = "null-ls"
format_lsp_mapping["yaml"] = "null-ls"
format_lsp_mapping["markdown"] = "null-ls"
format_lsp_mapping["graphql"] = "null-ls"
format_lsp_mapping["handlebars"] = "null-ls"
format_lsp_mapping["nginx"] = "null-ls"

-- xmllint
format_lsp_mapping["xml"] = "lemminx"

-- taplo
format_lsp_mapping["toml"] = "null-ls"

-- shfmt
format_lsp_mapping["sh"] = "null-ls"
-- stylua
format_lsp_mapping["lua"] = "null-ls"

-- rustfmt
format_lsp_mapping["rust"] = "null-ls"

format_lsp_mapping["http"] = "null-ls"

-- gofmt
format_lsp_mapping["go"] = "null-ls"

-- clang_format
format_lsp_mapping["c"] = "clangd"
format_lsp_mapping["cpp"] = "clangd"

-- black
format_lsp_mapping["python"] = "null-ls"

M.filter_format_lsp_client = function(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local cn = format_lsp_mapping[filetype]
  return client.name == cn
end

return M
