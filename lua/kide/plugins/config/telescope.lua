-- local actions = require("telescope.actions")
-- local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")

-- 支持预览 jar 包 class
local form_entry = require("telescope.from_entry")
local f_path = form_entry.path
form_entry.path = function(entry, validate, escape)
  escape = vim.F.if_nil(escape, true)
  local path
  if escape then
    path = entry.path and vim.fn.fnameescape(entry.path) or nil
  else
    path = entry.path
  end
  if path == nil then
    path = entry.filename
  end
  if path == nil then
    path = entry.value
  end
  if vim.startswith(path, "jdt://") then
    return path
  end
  return f_path(entry, validate, escape)
end

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "   ",
    selection_caret = " ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    winblend = 0,
    -- border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    -- use_less = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    -- file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    -- generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    dynamic_preview_title = true,
    results_title = false,
    -- file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    -- grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    -- qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    -- buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

    -- Default configuration for telescope goes here:
    -- config_key = value,
    preview = {
      timeout = 1000,
      filetype_hook = function(filepath, bufnr, opts)
        if vim.startswith(filepath, "jdt://") then
          require("kide.lsp.utils.jdtls").open_classfile(filepath, bufnr, opts.preview.timeout)
        end
        return true
      end,
    },
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key",
        -- ["<esc>"] = actions.close,
        -- ["<C-t>"] = trouble.open_with_trouble,
      },
      n = {
        -- ["<C-t>"] = trouble.open_with_trouble,
        ["q"] = require("telescope.actions").close,
      },
    },
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- even more opts
      }),
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
})
-- telescope.load_extension('fzf')
-- telescope.load_extension('gradle')
-- telescope.load_extension('maven_search')

-- 解决 telescope 打开的文件不折叠问题
-- https://github.com/nvim-telescope/telescope.nvim/issues/1277
vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      once = true,
      command = "normal! zx",
    })
  end,
})

require("telescope").load_extension("project")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("fzf")
require("telescope").load_extension("env")

require("kide.theme.gruvbox").load_telescope_highlights()
