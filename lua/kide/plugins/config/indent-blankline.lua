-- vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")

require("kide.theme.gruvbox").load_indent_blankline_highlights()
require("ibl").setup({
  exclude = {
    filetypes = {
      "lspinfo",
      "packer",
      "checkhealth",
      "man",
      "help",
      "terminal",
      "packer",
      "git",
      "gitcommit",
      "text",
      "txt",
      "NvimTree",
      "dashboard",
      "alpha",
      "Outline",
      "flutterToolsOutline",
      "TelescopePrompt",
      "TelescopeResults",
      "NeogitStatus",
      "NeogitPopup",
      "DiffviewFiles",
      "TelescopePrompt",
      "TelescopeResults",
      "",
      "dbui",
      "dbout",
    },
  },
})
