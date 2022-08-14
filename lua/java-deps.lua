local M = {}

local get_client = function()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name == "jdt.ls" then
      return client
    end
  end
end

local get_root_project_uri = function(client)
  client = client or get_client()
  if client then
    return "file://" .. client.config.root_dir
  end
end

local request = function(bufnr, method, params, handler)
  vim.lsp.buf_request(bufnr, method, params, handler)
end

M.NodeKind = {
  WORKSPACE = 1,
  PROJECT = 2,
  CONTAINER = 3,
  PACKAGEROOT = 4,
  PACKAGE = 5,
  PRIMARYTYPE = 6,
  FOLDER = 7,
  FILE = 8,

  CLASS = 11,
  INTERFACE = 12,
  ENUM = 13,
}
M.symbols = {}
M.symbols.kinds = {
  "WORKSPACE",
  "PROJECT",
  "CONTAINER",
  "PACKAGEROOT",
  "PACKAGE",
  "PRIMARYTYPE",
  "FOLDER",
  "FILE",

  [11] = "CLASS",
  [12] = "INTERFACE",
  [13] = "ENUM",
  [21] = "JAR",
}

M.config = {
  options = {
    show_guides = true,
    auto_clise = false,
    width = 40,
    relative_width = true,
    symbols = {
      FILE = { icon = "", hl = "TSURI" },
      WORKSPACE = { icon = "", hl = "TSNamespace" },
      CONTAINER = { icon = "", hl = "TSMethod" },
      PACKAGE = { icon = "", hl = "TSNamespace" },
      PRIMARYTYPE = { icon = "ﴯ", hl = "TSType" },
      PROJECT = { icon = "פּ", hl = "TSType" },
      PACKAGEROOT = { icon = "", hl = "TSType" },
      FOLDER = { icon = "", hl = "TSType" },
      CLASS = { icon = "C", hl = "TSType" },
      ENUM = { icon = "E", hl = "TSType" },
      INTERFACE = { icon = "I", hl = "TSType" },
      JAR = { icon = "", hl = "TSKeyword" },
    },
  },
}
M.state = {
  root_cache = nil,
  root_view = nil,
  jdt_dep_win = nil,
  jdt_dep_buf = nil,
  code_win = 0,
  code_buf = 0,
}
M.project_list = function(code_buf, handler)
  local params = {}
  params.command = "java.project.list"
  params.arguments = {
    M.state.root_cache.project_uri,
  }
  request(code_buf, "workspace/executeCommand", params, function(err, projects)
    if err then
      vim.notify(err.message, vim.log.levels.WARN)
    elseif projects then
      handler(projects)
    end
  end)
end

M.get_package_data = function(buf, node, handler)
  buf = buf or 0

  local params0 = {}
  params0.command = "java.getPackageData"
  params0.arguments = {
    kind = node.kind,
    projectUri = M.state.root_cache.project_uri,
    path = node.path,
  }
  if node.root_project then
    params0.arguments.projectUri = node.root_project.uri
  end
  if node.container then
    params0.arguments.projectUri = node.container.uri
  end
  if node.kind == M.NodeKind.PROJECT then
    params0.arguments.projectUri = node.uri
  end

  if node.kind == M.NodeKind.PACKAGEROOT then
    params0.arguments.rootPath = M.state.root_cache.project_uri
    params0.arguments.handlerIdentifier = node.handlerIdentifier
    params0.arguments.isHierarchicalView = true
  end
  if node.kind == M.NodeKind.PACKAGE then
    params0.arguments.isHierarchicalView = true
    params0.arguments.path = node.name
    params0.arguments.handlerIdentifier = node.handlerIdentifier
  end
  -- 获取项目结构
  request(buf, "workspace/executeCommand", params0, function(err0, packages)
    if err0 then
      print(err0.message)
    elseif packages then
      handler(node, packages)
    end
  end)
end

M.write_buf = function(bufnr, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end
M.markers = {
  bottom = "└",
  middle = "├",
  vertical = "│",
  horizontal = "─",
}

local function table_to_str(t)
  local ret = ""
  for _, value in ipairs(t) do
    ret = ret .. tostring(value)
  end
  return ret
end
local function str_to_table(str)
  local t = {}
  for i = 1, #str do
    t[i] = str:sub(i, i)
  end
  return t
end

M.parse_lines = function(root_view)
  local lines = {}
  local hl_info = {}
  -- .depth
  for _, v in ipairs(root_view) do
    local line = str_to_table(string.rep(" ", v.depth))

    if M.config.options.show_guides then
      -- makes the guides
      for index, _ in ipairs(line) do
        -- all items start with a space (or two)
        if index == 1 then
          line[index] = " "
          -- if index is last, add a bottom marker if current item is last,
          -- else add a middle marker
        elseif index == #line then
          if v.isLast then
            line[index] = M.markers.bottom
          else
            line[index] = M.markers.middle
          end
          -- else if the parent was not the last in its group, add a
          -- vertical marker because there are items under us and we need
          -- to point to those
          -- else
          --   line[index] = M.markers.vertical
        end
      end
    end
    local final_prefix = {}
    -- Add 1 space between the guides
    for _, l in ipairs(line) do
      table.insert(final_prefix, l)
      table.insert(final_prefix, " ")
    end

    local string_prefix = table_to_str(final_prefix)
    local hl_start = #string_prefix
    local hl_end = #string_prefix + #v.icon

    -- table.insert(lines, string_prefix .. v.icon .. " " .. v.name .. ":" .. v.kind .. ":" .. v.order)
    table.insert(lines, string_prefix .. v.icon .. " " .. v.name)
    local hl_type = M.config.options.symbols[M.symbols.kinds[v.type_kind]].hl
    table.insert(hl_info, { hl_start, hl_end, hl_type })
  end
  return lines, hl_info
end

local function type_kind(node)
  if node.metaData and node.metaData.TypeKind then
    return node.metaData.TypeKind + 10
  end
  if vim.endswith(node.name, ".jar") then
    return 21
  end
  return node.kind
end
function M.flatten(items, depth)
  if items and items[#items] then
    items[#items].isLast = true
  end
  local ret = {}
  for _, value in ipairs(items) do
    local idepth = depth or value.depth or 1
    value.depth = idepth
    value.type_kind = type_kind(value)
    value.icon = M.config.options.symbols[M.symbols.kinds[value.type_kind]].icon
    table.insert(ret, value)
    if value.children ~= nil then
      local inner = M.flatten(value.children, idepth + 1)
      for _, value_inner in ipairs(inner) do
        table.insert(ret, value_inner)
      end
    end
  end
  return ret
end

local function sort_node_c(node)
  if node == nil or node.children == nil then
    return
  end
  table.sort(node.children, function(a, b)
    if a.order ~= b.order then
      return a.order < b.order
    end
    if a.kind == b.kind then
      if
        a.kind == M.NodeKind.PROJECT
        or a.kind == M.NodeKind.PRIMARYTYPE
        or a.kind == M.NodeKind.PACKAGEROOT
        or a.kind == M.NodeKind.PACKAGE
      then
        if a.name ~= b.name then
          return a.name:upper() < b.name:upper()
        end
      end
    end
    return false
  end)
end

local hlns = vim.api.nvim_create_namespace("java-deps-icon-highlight")
function M.add_highlights(bufnr, hl_info)
  for line, line_hl in ipairs(hl_info) do
    local hl_start, hl_end, hl_type = unpack(line_hl)
    vim.api.nvim_buf_add_highlight(bufnr, hlns, hl_type, line - 1, hl_start, hl_end)
  end
end

local function _auto_close(bufnr)
  local clean_diagnostic = vim.api.nvim_create_augroup("clean_java_deps_view", { clear = true })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = clean_diagnostic,
    buffer = bufnr,
    callback = function()
      vim.api.nvim_del_augroup_by_id(clean_diagnostic)
      M._clean()
    end,
  })
end
local function _render()
  M.state.root_view = M.flatten(M.state.root_cache.children)
  local lines, hl_info = M.parse_lines(M.state.root_view)
  if M.state.jdt_dep_buf == nil then
    M.state.jdt_dep_buf, M.state.jdt_dep_win = M.setup_view()
    M.keymaps(M.state.jdt_dep_buf, true)
    _auto_close(M.state.jdt_dep_buf)
  end
  M.write_buf(M.state.jdt_dep_buf, lines)
  M.add_highlights(M.state.jdt_dep_buf, hl_info)
end

local function setup_keymaps(bufnr)
  local buf_map = function(key, action)
    vim.api.nvim_buf_set_keymap(bufnr, "n", key, action, { silent = true, noremap = true })
  end
  buf_map("o", ":lua require('java-deps')._open_file(false)<Cr>")
end

local function get_cmp_uri(code_buf)
  local name = vim.api.nvim_buf_get_name(code_buf)
  if not vim.startswith(name, "jdt://") then
    return "file://" .. name
  end
end
local function handler_debs(bufnr, cnode)
  if
    cnode.kind == M.NodeKind.PRIMARYTYPE
    or cnode.kind == M.NodeKind.FILE
    or cnode.kind == M.NodeKind.CLASS
    or cnode.kind == M.NodeKind.INTERFACE
    or cnode.kind == M.NodeKind.ENUM
  then
    return
  end
  if cnode.children then
    cnode.children = nil
    cnode.isLast = false
    _render()
  else
    if M.state.code_buf_uri == nil then
      M.state.code_buf_uri = get_cmp_uri(bufnr)
    end
    M.get_package_data(bufnr, cnode, function(node, iresp)
      node.children = {}
      for _, value in ipairs(iresp) do
        if value.uri and vim.startswith(value.uri, M.state.code_buf_uri) then
          value.current = true
        end
        if M.NodeKind.CONTAINER == value.kind then
          value.root_project = node
        end
        if M.NodeKind.PACKAGEROOT == value.kind and vim.startswith(value.name, "src/") then
          value.order = 0
        else
          value.order = 1
        end
        if
          M.NodeKind.CONTAINER == value.kind
          and not vim.startswith(value.name, "JRE System Library")
          and not vim.startswith(value.name, "Maven Dependencies")
        then
          M.get_package_data(bufnr, value, function(inode, iiresp)
            for _, iv in ipairs(iiresp) do
              if M.NodeKind.PACKAGEROOT == iv.kind and vim.startswith(iv.name, "src/") then
                iv.order = 0
              else
                iv.order = 1
              end
              iv.container = inode
              table.insert(node.children, iv)
            end
            sort_node_c(node)
            _render()
          end)
        else
          table.insert(node.children, value)
        end
      end
      node.isLast = true
      sort_node_c(node)
      _render()
    end)
  end
end
M.java_projects = function()
  if M.state.root_cache == nil then
    M.state.root_cache = {}
    M.state.root_cache.project_uri = get_root_project_uri()
  end
  if M.state.root_cache.project_uri == nil then
    M.state.root_cache = nil
    vim.notify("Failed to get project root directory", vim.log.levels.WARN)
    return
  end
  local code_buf = vim.api.nvim_get_current_buf()
  M.state.code_buf = code_buf
  M.state.code_buf_uri = get_cmp_uri(code_buf)
  if M.state.root_view == nil then
    M.state.root_view = {}
  end
  M.project_list(code_buf, function(projects)
    for _, project in ipairs(projects) do
      project.order = 0
    end
    M.state.root_cache.children = projects
    for _, project in ipairs(M.state.root_cache.children) do
      handler_debs(code_buf, project)
    end
    _render()
    setup_keymaps(M.state.jdt_dep_buf)
  end)
end

function M._open_file(change_focus)
  local current_line = vim.api.nvim_win_get_cursor(M.state.jdt_dep_win)[1]
  local node = M.state.root_view[current_line]
  handler_debs(M.state.code_buf, node)
  if change_focus then
    vim.fn.win_gotoid(M.state.code_win)
  end
  if M.config.options.auto_close then
    M.close_outline()
  end
end

function M.get_split_command()
  if M.config.options.position == "left" then
    return "topleft vs"
  else
    return "botright vs"
  end
end
function M.get_window_width()
  if M.config.options.relative_width then
    return math.ceil(vim.o.columns * (M.config.options.width / 100))
  else
    return M.options.width
  end
end
M.setup_view = function()
  -- create a scratch unlisted buffer
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- delete buffer when window is closed / buffer is hidden
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "delete")
  -- create a split
  vim.cmd(M.get_split_command())
  -- resize to a % of the current window size
  vim.cmd("vertical resize " .. M.get_window_width())

  -- get current (outline) window and attach our buffer to it
  local winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winnr, bufnr)

  -- window stuff
  vim.api.nvim_win_set_option(winnr, "number", false)
  vim.api.nvim_win_set_option(winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(winnr, "winfixwidth", true)
  -- buffer stuff
  vim.api.nvim_buf_set_name(bufnr, "Java Projects")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "JavaProjects")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  if M.config.options.show_numbers or M.config.options.show_relative_numbers then
    vim.api.nvim_win_set_option(winnr, "nu", true)
  end

  if M.config.options.show_relative_numbers then
    vim.api.nvim_win_set_option(winnr, "rnu", true)
  end

  return bufnr, winnr
end

function M._clean()
  M.state.jdt_dep_buf = nil
  M.state.jdt_dep_win = nil
  M.state.root_cache = nil
end

function M.close_jdt_dep()
  if M.state.jdt_dep_buf then
    vim.api.nvim_win_close(M.state.jdt_dep_win, true)
    M._clean()
  end
end

function M.open_jdt_dep()
  if M.state.jdt_dep_buf == nil then
    M.java_projects()
  end
end
function M.java_deps_toggle()
  if M.state.jdt_dep_buf == nil then
    M.java_projects()
  else
    M.close_jdt_dep()
  end
end

function M.setup(config)
  if config then
    M.config = vim.tbl_extend("force", M.config, config)
  end
end
function M.attach(client, bufnr)
  if M.state.root_cache == nil then
    M.state.root_cache = {}
    M.state.root_cache.project_uri = get_root_project_uri(client)
  end
  if M.state.root_cache.project_uri then
    M.keymaps(bufnr)
  end
end
function M.keymaps(bufnr, view)
  local buf_map = function(key, action)
    vim.api.nvim_buf_set_keymap(bufnr, "n", key, action, { silent = true, noremap = true })
  end
  buf_map("<leader>p", ":lua require('java-deps').java_deps_toggle(false)<Cr>")
  if view then
    buf_map("q", ":lua require('java-deps').close_jdt_dep()<Cr>")
  end
end

return M
