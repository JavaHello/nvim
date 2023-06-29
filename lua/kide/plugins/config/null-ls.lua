local null_ls = require("null-ls")

-- register any number of sources simultaneously
local sources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "css",
      "scss",
      "less",
      "html",
      "json",
      "jsonc",
      "yaml",
      "markdown",
      "graphql",
      "handlebars",
    },
  }),
  -- null_ls.builtins.formatting.jq,
  -- xml
  -- null_ls.builtins.formatting.xmllint,
  -- toml
  null_ls.builtins.formatting.taplo,
  -- sh
  null_ls.builtins.code_actions.shellcheck,
  null_ls.builtins.diagnostics.shellcheck,
  null_ls.builtins.formatting.shfmt,
  -- lua
  null_ls.builtins.formatting.stylua,
  -- word
  null_ls.builtins.diagnostics.write_good.with({
    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  }),
  -- md
  -- null_ls.builtins.diagnostics.markdownlint.with({
  --   method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  -- }),
  -- null_ls.builtins.code_actions.gitsigns,
  -- sql
  null_ls.builtins.formatting.sql_formatter.with({
    filetypes = {
      "sql",
      "mysql",
    },
  }),
  -- null_ls.builtins.formatting.google_java_format,
  -- null_ls.builtins.diagnostics.semgrep,
  null_ls.builtins.formatting.rustfmt.with({
    extra_args = function(params)
      local Path = require("plenary.path")
      local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")

      if cargo_toml:exists() and cargo_toml:is_file() then
        for _, line in ipairs(cargo_toml:readlines()) do
          local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
          if edition then
            return { "--edition=" .. edition }
          end
        end
      end
      -- default edition when we don't find `Cargo.toml` or the `edition` in it.
      return { "--edition=2021" }
    end,
  }),
  -- null_ls.builtins.diagnostics.semgrep.with({
  -- 	method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  -- 	extra_args = { "--config", "p/java" },
  -- }),
  null_ls.builtins.formatting.gofmt,
  -- null_ls.builtins.formatting.clang_format.with({
  --   filetypes = {
  --     "c",
  --     "cpp",
  --   },
  -- }),
  null_ls.builtins.formatting.nginx_beautifier,

  -- python
  null_ls.builtins.formatting.black,
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

if "Y" == vim.env["SEMGREP_ENABLE"] then
  table.insert(sources, null_ls.builtins.diagnostics.semgrep)
elseif "Y" == vim.env["PMD_ENABLE"] then
  table.insert(
    sources,
    null_ls.builtins.diagnostics.pmd.with({
      extra_args = {
        "--rulesets",
        "category/java/bestpractices.xml,category/jsp/bestpractices.xml",
      },
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    })
  )
end

null_ls.setup({
  sources = sources,
})
