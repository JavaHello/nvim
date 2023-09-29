-- vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")

require("ibl").setup({
  --    show_end_of_line = true,
  --    space_char_blankline = " ",
  show_current_context = true,
  --    show_current_context_start = true,
  disable_with_nolist = true,
  -- filetype_exclude = { "help", "terminal", "packer", "NvimTree", "git", "text" },
  filetype_exclude = {
    "lspinfo",
    "packer",
    "checkhealth",
    "man",
    "help",
    "terminal",
    "packer",
    -- "markdown",
    "git",
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
  use_treesitter = true,
})

require("kide.theme.gruvbox").load_indent_blankline_highlights()
