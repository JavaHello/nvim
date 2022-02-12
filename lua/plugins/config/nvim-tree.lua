require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_setup       = false,
  ignore_ft_on_setup  = { "dashboard" },
  auto_close          = true,
  auto_reload_on_write = true,
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = false,
  actions             = {
    open_file = {
      quit_on_open = true,
    },
  },
  update_to_buf_dir   = {
    enable = false,
    auto_open = false,
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {".git"}
  },
  git = {
    enable = false,
    ignore = false,
    timeout = 500,
  },
  view = {
    width = '40%',
    height = '40%',
    hide_root_folder = true,
    side = 'left',
    auto_resize = true,
    mappings = {
      custom_only = false,
      list = {}
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  }
}


