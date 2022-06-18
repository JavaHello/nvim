local config = {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      -- "dap-repl", "dapui_watches", "dapui_stacks", "dapui_breakpoints", "dapui_scopes"
    },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    -- lualine_c = {'filename', 'lsp_progress'},
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    -- lualine_b = {function() return require('lsp-status').status() end},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'quickfix', 'toggleterm', 'nvim-tree', 'fugitive', 'symbols-outline' }
}

-- nvim-dap-ui extensions
local dap = {
  sections = {
    lualine_a = { 'filename' }
  },
  filetypes = {
    "dap-repl", "dapui_watches", "dapui_stacks", "dapui_breakpoints", "dapui_scopes"
  },
};

table.insert(config.extensions, dap)

-- nvim-sqls extensions
local db_connection_value
local db_database_value = ''
require("sqls.events").add_subscriber("connection_choice", function(event)
  local cs = vim.split(event.choice, ' ');
  db_connection_value = cs[3]
  local db = vim.split(cs[4], '/')
  if db[2] then
    db_database_value = db[2]
  end
end)
require("sqls.events").add_subscriber("database_choice", function(event)
  db_database_value = event.choice
end)
local function db_info()
  if db_connection_value then
    return db_connection_value .. '->' .. db_database_value
  end
end

local sqls = {
}
sqls.sections = vim.deepcopy(config.sections)
table.insert(sqls.sections.lualine_c, db_info)
sqls.filetypes = {
  "sql"
}
table.insert(config.extensions, sqls)

require('lualine').setup(config)
