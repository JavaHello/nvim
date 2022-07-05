require("lsp_signature").on_attach({
  bind = true,
  use_lspsaga = false,
  floating_window = true,
  fix_pos = true,
  hint_enable = true,
  hi_parameter = "Search",
  handler_opts = { "double" },
})
