require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_setup       = false,
  ignore_ft_on_setup  = { "dashboard" },
  -- auto_close          = true,
  auto_reload_on_write = true,
  open_on_tab         = false,
  hijack_cursor       = true,
  update_cwd          = false,
  actions             = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
    },
    open_file = {
      quit_on_open = true,
      resize_window = true,
      window_picker = {
        enable = true,
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
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
    custom = {".git"},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
  },
  view = {
    width = '34%',
    height = '40%',
    hide_root_folder = true,
    side = 'left',
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {}
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  }
}


local g = vim.g


g.nvim_tree_indent_markers = 1

g.nvim_tree_special_files = {}

g.nvim_tree_window_picker_exclude = {
  filetype = { "notify", "packer", "qf" },
  buftype = { "terminal" },
}

-- g.nvim_tree_icons = {
--    default = "",
--    symlink = "",
--    git = {
--       deleted = "",
--       ignored = "◌",
--       renamed = "➜",
--       staged = "✓",
--       unmerged = "",
--       unstaged = "✗",
--       untracked = "★",
--    },
--    folder = {
--       default = "",
--       empty = "",
--       empty_open = "",
--       open = "",
--       symlink = "",
--       symlink_open = "",
--    },
-- }


g.nvim_tree_show_icons = {
  folders = 1,
  files = 1,
  git = 1,
}


