local null_ls = require("null-ls")

-- register any number of sources simultaneously
local sources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = { "html", "json", "javascript", "typescript", "yaml", "markdown" },
  }),
  null_ls.builtins.diagnostics.write_good.with({
    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  }),
  null_ls.builtins.code_actions.gitsigns,
  null_ls.builtins.formatting.sql_formatter,
  -- null_ls.builtins.formatting.google_java_format,
  -- null_ls.builtins.diagnostics.semgrep,
  null_ls.builtins.diagnostics.semgrep.with({
    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    extra_args = { "--config", "auto" },
  }),
}


local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- apply whatever logic you want (in this example, we'll only use null-ls)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- add to your shared on_attach callback
local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end


null_ls.setup({
  sources = sources,
  on_attach = function(client, bufnr)
    require('core.keybindings').maplsp(client, bufnr)
    on_attach(client, bufnr)
  end,
  -- debug = true,
})
