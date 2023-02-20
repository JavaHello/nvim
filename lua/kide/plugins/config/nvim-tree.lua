local function custom_callback(callback_name)
  return string.format(":lua require('kide.plugins.config.utils.treeutil').%s()<CR>", callback_name)
end
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  -- auto_close          = true,
  auto_reload_on_write = true,
  open_on_tab = false,
  hijack_cursor = true,
  actions = {
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
  update_focused_file = {
    enable = true,
    update_cwd = false,
    ignore_list = {},
  },
  system_open = {
    cmd = "",
    args = {},
  },
  filters = {
    dotfiles = false,
    custom = { "^.git$" },
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
  },
  view = {
    width = 34,
    -- height = 40,
    hide_root_folder = true,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {

        { key = "<leader>ff", cb = custom_callback("launch_find_files") },
        { key = "<leader>fg", cb = custom_callback("launch_live_grep") },
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = false,
      icons = {
        corner = "└",
        edge = "│",
        item = "│",
        none = " ",
      },
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
})

-- local g = vim.g

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
