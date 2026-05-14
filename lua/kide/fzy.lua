local M = {}
local selection_ns = vim.api.nvim_create_namespace("builtin_fuzzy_select_selection")
local match_ns = vim.api.nvim_create_namespace("builtin_fuzzy_select_matches")
local count_ns = vim.api.nvim_create_namespace("builtin_fuzzy_select_count")

local function stopinsert()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
end

local function select_opts(title)
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.8)
  local row = math.floor((lines - height) * 0.5)
  local col = math.floor((columns - width) * 0.5)
  local result_height = math.max(1, height - 2)

  return {
    input = {
      relative = "editor",
      style = "minimal",
      row = row,
      col = col,
      width = width,
      height = 1,
      focusable = true,
      border = { "╭", "─", "╮", "│", "┤", "─", "├", "│" },
      title = title,
      title_pos = "center",
    },
    result = {
      relative = "editor",
      style = "minimal",
      row = row + 2,
      col = col,
      width = width,
      height = result_height,
      focusable = true,
      border = { "├", "─", "┤", "│", "╯", "─", "╰", "│" },
      title = "Results",
      title_pos = "center",
    },
  }
end

local function set_scratch_options(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
end

local function set_lines(buf, lines)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end


local function set_range_highlight(buf, ns, hl_group, row, start_col, end_col)
  if end_col <= start_col then
    return
  end
  vim.api.nvim_buf_set_extmark(buf, ns, row, start_col, {
    end_col = end_col,
    hl_group = hl_group,
    priority = 100,
  })
end

local function close_window(state)
  if state.closed then
    return
  end
  state.closed = true
  if state.group then
    pcall(vim.api.nvim_del_augroup_by_id, state.group)
  end
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    pcall(vim.api.nvim_win_close, state.input_win, true)
  end
  if state.result_win and vim.api.nvim_win_is_valid(state.result_win) then
    pcall(vim.api.nvim_win_close, state.result_win, true)
  end
  if state.input_buf and vim.api.nvim_buf_is_valid(state.input_buf) then
    pcall(vim.api.nvim_buf_delete, state.input_buf, { force = true })
  end
  if state.result_buf and vim.api.nvim_buf_is_valid(state.result_buf) then
    pcall(vim.api.nvim_buf_delete, state.result_buf, { force = true })
  end
end

local function open_file(filename, open)
  if not filename or filename == "" then
    return
  end
  vim.cmd((open or "edit") .. " " .. vim.fn.fnameescape(filename))
end

local function render(state)
  if state.closed then
    return
  end
  if not state.input_buf or not vim.api.nvim_buf_is_valid(state.input_buf) then
    return
  end

  local query = state.query or ""
  local matches = {}
  local positions = {}

  if query == "" then
    matches = vim.list_slice(state.items, 1, state.max_results)

    for _ = 1, #matches do
      table.insert(positions, {})
    end
  else
    local fuzzy = vim.fn.matchfuzzypos(state.items, query)

    matches = vim.list_slice(fuzzy[1], 1, state.max_results)
    positions = vim.list_slice(fuzzy[2], 1, state.max_results)
  end

  state.matches = matches
  state.positions = positions
  if #matches > 0 then
    state.index = math.max(1, math.min(state.index, #matches))
  else
    state.index = 1
  end

  vim.api.nvim_buf_clear_namespace(state.input_buf, count_ns, 0, -1)
  vim.api.nvim_buf_set_extmark(state.input_buf, count_ns, 0, 0, {
    virt_text = { { ("  %d/%d"):format(#matches, #state.items), "Comment" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
    priority = 100,
  })

  if not state.result_buf or not vim.api.nvim_buf_is_valid(state.result_buf) then
    return
  end

  local lines = {}
  for _, item in ipairs(matches) do
    table.insert(lines, item)
  end

  set_lines(state.result_buf, lines)
  vim.api.nvim_buf_clear_namespace(state.result_buf, selection_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(state.result_buf, match_ns, 0, -1)


  for i, pos_list in ipairs(positions) do
    for _, pos in ipairs(pos_list or {}) do
      local col = pos
      set_range_highlight(state.result_buf, match_ns, "Search", i - 1, col, col + 1)
    end
  end

  if state.result_win and vim.api.nvim_win_is_valid(state.result_win) and #lines > 0 then
    pcall(vim.api.nvim_win_set_cursor, state.result_win, { math.min(state.index, #lines), 0 })
  end
end

local function current_query(state)
  if not state.input_buf or not vim.api.nvim_buf_is_valid(state.input_buf) then
    return ""
  end
  return vim.api.nvim_buf_get_lines(state.input_buf, 0, 1, false)[1] or ""
end

local function refresh_query(state)
  local query = current_query(state)
  if query == state.query then
    return
  end
  state.query = query
  state.index = 1
  render(state)
end

local function accept(state)
  local choice = state.matches and state.matches[state.index]
  stopinsert()
  close_window(state)

  if choice and choice ~= "" and state.on_choice then
    vim.schedule(function()
      state.on_choice(choice)
    end)
  end
end

local function move(state, delta)
  local count = #(state.matches or {})
  if count == 0 then
    return
  end

  state.index = state.index + delta

  if state.index < 1 then
    state.index = count
  elseif state.index > count then
    state.index = 1
  end

  render(state)
end

local function run_lines(lines, opts)
  opts = opts or {}

  if vim.tbl_isempty(lines) then
    vim.notify(opts.empty_message or "没有可供查找的内容", vim.log.levels.INFO)
    return
  end

  stopinsert()

  local title = opts.title or "Select"
  local win_opts = select_opts(title)

  local state = {
    items = lines,
    matches = {},
    query = opts.query or "",
    index = 1,
    max_results = math.max(1, win_opts.result.height),
    on_choice = opts.on_choice,
    closed = false,
  }

  state.input_buf = vim.api.nvim_create_buf(false, true)
  state.result_buf = vim.api.nvim_create_buf(false, true)
  set_scratch_options(state.input_buf)
  set_scratch_options(state.result_buf)
  vim.bo[state.result_buf].modifiable = false

  state.input_win = vim.api.nvim_open_win(state.input_buf, true, win_opts.input)
  state.result_win = vim.api.nvim_open_win(state.result_buf, false, win_opts.result)
  vim.wo[state.input_win].number = false
  vim.wo[state.input_win].relativenumber = false
  vim.wo[state.result_win].number = false
  vim.wo[state.result_win].relativenumber = false
  vim.wo[state.result_win].wrap = false
  vim.wo[state.result_win].cursorline = true

  vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { state.query })
  vim.api.nvim_win_set_cursor(state.input_win, { 1, #state.query })

  local function focus_input(insert)
    if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
      vim.api.nvim_set_current_win(state.input_win)
      if insert then
        vim.cmd("startinsert!")
      end
    end
  end

  local function map(buf, mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = buf,
      nowait = true,
      silent = true,
    })
  end

  local function map_result(lhs, rhs)
    map(state.result_buf, "n", lhs, rhs)
  end

  local function map_both(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = state.input_buf,
      nowait = true,
      silent = true,
    })
    vim.keymap.set("n", lhs, rhs, {
      buffer = state.result_buf,
      nowait = true,
      silent = true,
    })
  end

  map_both({ "i", "n" }, "<CR>", function()
    accept(state)
  end)

  map_both({ "i", "n" }, "<Esc>", function()
    close_window(state)
  end)

  map_both("n", "q", function()
    close_window(state)
  end)

  map_both({ "i", "n" }, "<C-c>", function()
    close_window(state)
  end)

  map_both("n", "j", function()
    move(state, 1)
  end)

  map_both("n", "k", function()
    move(state, -1)
  end)

  map_both({ "i", "n" }, "<Down>", function()
    move(state, 1)
  end)

  map_both({ "i", "n" }, "<Up>", function()
    move(state, -1)
  end)

  map_both({ "i", "n" }, "<C-n>", function()
    move(state, 1)
  end)

  map_both({ "i", "n" }, "<C-p>", function()
    move(state, -1)
  end)

  map_result("i", function()
    focus_input(true)
  end)

  map_result("/", function()
    focus_input(true)
  end)

  state.group = vim.api.nvim_create_augroup("kide-fzy-" .. state.input_buf, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = state.group,
    buffer = state.input_buf,
    callback = function()
      refresh_query(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = state.input_buf,
    callback = function()
      close_window(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = state.result_buf,
    callback = function()
      close_window(state)
    end,
  })

  render(state)
  focus_input(true)
end

function M.select(lines, opts)
  run_lines(lines, opts or {})
end


local function file_source()
  if vim.fn.executable("fd") == 1 then
    return "fd --type f --hidden --follow --exclude .git"
  end

  if vim.fn.executable("rg") == 1 then
    return "rg --files --hidden --glob '!.git/**'"
  end

  return "find . -type f -not -path '*/.git/*' | sed 's#^\\./##'"
end

local function run_source(source_cmd, opts)
  opts = opts or {}

  local lines = vim.fn.systemlist(source_cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("source command 执行失败: " .. source_cmd, vim.log.levels.ERROR)
    return
  end

  run_lines(lines, opts)
end

function M.files(opts)
  opts = opts or {}

  run_source(file_source(), {
    title = "Files",
    query = opts.query,
    empty_message = "没有文件",
    on_choice = function(choice)
      open_file(choice, opts.open)
    end,
  })
end

local function buffer_lines()
  local lines = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted then
      local name = vim.api.nvim_buf_get_name(bufnr)

      if name == "" then
        name = "[No Name]"
      else
        name = vim.fn.fnamemodify(name, ":~:.")
      end

      local modified = vim.bo[bufnr].modified and "+" or " "
      table.insert(lines, ("%d\t%s\t%s"):format(bufnr, modified, name))
    end
  end

  return lines
end

function M.buffers(opts)
  opts = opts or {}

  run_lines(buffer_lines(), {
    title = "Buffers",
    query = opts.query,
    empty_message = "没有 listed buffer",
    on_choice = function(choice)
      local bufnr = tonumber(choice:match("^(%d+)\t"))

      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_set_current_buf(bufnr)
      end
    end,
  })
end

local function oldfile_lines()
  local lines = {}
  local seen = {}

  for _, filename in ipairs(vim.v.oldfiles) do
    if not seen[filename] and vim.fn.filereadable(filename) == 1 then
      seen[filename] = true
      table.insert(lines, vim.fn.fnamemodify(filename, ":~:."))
    end
  end

  return lines
end

function M.oldfiles(opts)
  opts = opts or {}

  run_lines(oldfile_lines(), {
    title = "Oldfiles",
    query = opts.query,
    empty_message = "没有 oldfiles",
    on_choice = function(choice)
      open_file(choice, opts.open)
    end,
  })
end

local function qflist_lines()
  local lines = {}

  for idx, item in ipairs(vim.fn.getqflist()) do
    if item.valid == 1 then
      local filename = item.filename

      if (not filename or filename == "") and item.bufnr and item.bufnr > 0 then
        filename = vim.api.nvim_buf_get_name(item.bufnr)
      end

      if filename and filename ~= "" then
        local text = item.text or ""
        text = text:gsub("%s+", " ")

        table.insert(
          lines,
          ("%d\t%s:%d:%d\t%s"):format(
            idx,
            vim.fn.fnamemodify(filename, ":~:."),
            item.lnum or 1,
            item.col or 1,
            text
          )
        )
      end
    end
  end

  return lines
end

function M.quickfix(opts)
  opts = opts or {}

  run_lines(qflist_lines(), {
    title = "Quickfix",
    query = opts.query,
    empty_message = "quickfix 为空",
    on_choice = function(choice)
      local idx = tonumber(choice:match("^(%d+)\t"))

      if idx then
        vim.cmd("cc " .. idx)
      end
    end,
  })
end

return M
