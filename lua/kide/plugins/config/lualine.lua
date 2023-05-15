local config = {
  options = {
    icons_enabled = true,
    theme = "gruvbox",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      "alpha",
    },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    -- lualine_c = {'filename', 'lsp_progress'},
    lualine_c = {
      {
        function()
          local names = {}
          for _, server in pairs(vim.lsp.buf_get_clients(0)) do
            table.insert(names, server.name)
          end
          if vim.tbl_isempty(names) then
            return " [No LSP]"
          else
            return " [" .. table.concat(names, " ") .. "]"
          end
        end,
      },
      "filename",
      "navic",
    },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    -- lualine_b = {function() return require('lsp-status').status() end},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "quickfix", "toggleterm", "fugitive", "symbols-outline", "nvim-dap-ui" },
}

local dap = {}
dap.sections = {
  lualine_a = {
    { "filename", file_status = false },
  },
}
dap.filetypes = {
  "dap-terminal",
  "dapui_console",
}
table.insert(config.extensions, dap)

-- NvimTree
local nerdtree = require("lualine.extensions.nerdtree")

local nvim_tree = {}
nvim_tree.sections = vim.deepcopy(nerdtree.sections)
nvim_tree.sections.lualine_b = { "branch" }
nvim_tree.filetypes = {
  "NvimTree",
}
table.insert(config.extensions, nvim_tree)

-- nvim-sqls extensions
-- local db_connection_value = "default"
-- local db_database_value = "default"
-- require("sqls.events").add_subscriber("connection_choice", function(event)
--   local cs = vim.split(event.choice, " ")
--   db_connection_value = cs[3]
--   local db = vim.split(cs[4], "/")
--   if db[2] and db_database_value == "default" then
--     db_database_value = db[2]
--   end
-- end)
-- require("sqls.events").add_subscriber("database_choice", function(event)
--   db_database_value = event.choice
-- end)
-- local function db_info()
--   return db_connection_value .. "->" .. db_database_value
-- end
--
-- local sqls = {}
-- sqls.sections = vim.deepcopy(config.sections)
-- table.insert(sqls.sections.lualine_c, db_info)
-- sqls.filetypes = {
--   "sql",
-- }
-- table.insert(config.extensions, sqls)

-- DiffviewFilePanel
local diffview = {}
diffview.sections = {
  lualine_a = {
    { "filename", file_status = false },
  },
}
diffview.filetypes = {
  "DiffviewFiles",
}
table.insert(config.extensions, diffview)

-- db-ui
local dbui = {}
dbui.sections = {
  lualine_a = {
    { "filename", file_status = false },
  },
}
dbui.filetypes = {
  "dbui",
  "dbout",
}
table.insert(config.extensions, dbui)

-- JavaProjects
local java_projects = {}
java_projects.sections = {
  lualine_a = {
    { "filename", file_status = false },
  },
}
java_projects.filetypes = {
  "JavaProjects",
}
table.insert(config.extensions, java_projects)
require("lualine").setup(config)
