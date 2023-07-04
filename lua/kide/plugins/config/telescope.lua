-- local actions = require("telescope.actions")
-- local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")

-- 支持预览 jar 包 class
local form_entry = require("telescope.from_entry")
local f_path = form_entry.path
form_entry.path = function(entry, validate, escape)
  if entry.filename and vim.startswith(entry.filename, "jdt://") then
    return entry.filename
  end
  return f_path(entry, validate, escape)
end

local utils = require("telescope.utils")
local set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local l_edit = set.edit
set.edit = function(prompt_bufnr, command)
  local entry = action_state.get_selected_entry()

  if not entry then
    utils.notify("actions.set.edit", {
      msg = "Nothing currently selected",
      level = "WARN",
    })
    return
  end

  local filename, row, col

  filename = entry.path or entry.filename
  if not vim.startswith(filename, "jdt://") then
    l_edit(prompt_bufnr, command)
    return
  end

  row = entry.row or entry.lnum
  col = vim.F.if_nil(entry.col, 1)

  local picker = action_state.get_current_picker(prompt_bufnr)
  require("telescope.pickers").on_close_prompt(prompt_bufnr)
  pcall(vim.api.nvim_set_current_win, picker.original_win_id)
  local win_id = picker.get_selection_window(picker, entry)

  if picker.push_cursor_on_edit then
    vim.cmd("normal! m'")
  end

  if picker.push_tagstack_on_edit then
    local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
    local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
    vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")
  end

  if win_id ~= 0 and a.nvim_get_current_win() ~= win_id then
    vim.api.nvim_set_current_win(win_id)
  end

  if vim.api.nvim_buf_get_name(0) ~= filename or command ~= "edit" then
    local bufnr = vim.uri_to_bufnr(filename)
    vim.bo[bufnr].buflisted = true
    vim.api.nvim_win_set_buf(win_id, bufnr)
  end

  if row and col then
    pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
  end
end

local previewers = require("telescope.previewers")
previewers.buffer_previewer_maker = require("kide.plugins.config.telescope.buffer_previewer").file_maker

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
          return false
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
