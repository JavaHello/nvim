require("kide.core.keybindings").ufo_mapkey()

-- Option 3: treesitter as a main provider instead
-- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
local ftMap = {
  c = { "treesitter" },
  cpp = { "treesitter" },
  rust = { "treesitter" },
  java = { "treesitter" },
  lua = { "treesitter" },
  html = { "treesitter" },
  nginx = { "indent" },
  vim = "indent",
  python = { "indent" },
}
require("ufo").setup({
  provider_selector = function(bufnr, filetype, buftype)
    -- return { "treesitter", "indent" }
    return ftMap[filetype]
  end,
})
