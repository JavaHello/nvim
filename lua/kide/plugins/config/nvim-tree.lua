local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  api.config.mappings.default_on_attach(bufnr)

  local treeutils = require("kide.plugins.config.utils.treeutil")

  vim.keymap.set("n", "<leader>ff", treeutils.launch_find_files, opts("Launch Find Files"))
  vim.keymap.set("n", "<leader>fg", treeutils.launch_live_grep, opts("Launch Live Grep"))
end

require("nvim-tree").setup({
  on_attach = on_attach,
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
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "dbui", "dbout" },
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
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  renderer = {
    root_folder_label = false,
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
