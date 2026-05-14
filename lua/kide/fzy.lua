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

local function set_line_highlight(buf, ns, hl_group, row)
  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    line_hl_group = hl_group,
    priority = 50,
  })
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

  local input_line = (state.prompt or "> ") .. query
  set_lines(state.input_buf, { input_line })
  vim.api.nvim_buf_clear_namespace(state.input_buf, count_ns, 0, -1)
  if query ~= "" then
    set_range_highlight(state.input_buf, count_ns, "Search", 0, #state.prompt, #state.prompt + #query)
  end
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
  for i, item in ipairs(matches) do
    table.insert(lines, "  " .. item)
  end

  if #matches == 0 then
    if query == "" then
      table.insert(lines, "  输入内容开始筛选")
    else
      table.insert(lines, "  没有匹配结果")
    end
  end

  set_lines(state.result_buf, lines)
  vim.api.nvim_buf_clear_namespace(state.result_buf, selection_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(state.result_buf, match_ns, 0, -1)

  if #matches > 0 then
    set_line_highlight(state.result_buf, selection_ns, "CursorLine", state.index - 1)
  end

  for i, pos_list in ipairs(positions) do
    local prefix_len = 2

    for _, pos in ipairs(pos_list or {}) do
      local col = prefix_len + pos
      set_range_highlight(state.result_buf, match_ns, "Search", i - 1, col, col + 1)
    end
  end

  if state.result_win and vim.api.nvim_win_is_valid(state.result_win) and #lines > 0 then
    pcall(vim.api.nvim_win_set_cursor, state.result_win, { math.min(state.index, #lines), 0 })
  end
end

local function accept(state)
  local choice = state.matches and state.matches[state.index]
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

local function feed_query(state, char)
  state.query = state.query .. char
  state.index = 1
  render(state)
end

local function backspace(state)
  if state.query == "" then
    return
  end

  state.query = state.query:sub(1, -2)
  state.index = 1
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
    prompt = opts.prompt or "> ",
    index = 1,
    max_results = math.max(1, win_opts.result.height),
    on_choice = opts.on_choice,
  }

  state.input_buf = vim.api.nvim_create_buf(false, true)
  state.result_buf = vim.api.nvim_create_buf(false, true)
  set_scratch_options(state.input_buf)
  set_scratch_options(state.result_buf)
  vim.bo[state.input_buf].modifiable = false
  vim.bo[state.result_buf].modifiable = false

  state.input_win = vim.api.nvim_open_win(state.input_buf, true, win_opts.input)
  state.result_win = vim.api.nvim_open_win(state.result_buf, false, win_opts.result)
  vim.wo[state.input_win].number = false
  vim.wo[state.input_win].relativenumber = false
  vim.wo[state.result_win].number = false
  vim.wo[state.result_win].relativenumber = false
  vim.wo[state.result_win].wrap = false
  vim.wo[state.result_win].cursorline = true

  local function map(buf, lhs, rhs)
    vim.keymap.set("n", lhs, rhs, {
      buffer = buf,
      nowait = true,
      silent = true,
    })
  end

  local function map_all(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, {
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

  map_all("<CR>", function()
    accept(state)
  end)

  map_all("<Esc>", function()
    close_window(state)
  end)

  map_all("q", function()
    close_window(state)
  end)

  map_all("<C-c>", function()
    close_window(state)
  end)

  map_all("j", function()
    move(state, 1)
  end)

  map_all("k", function()
    move(state, -1)
  end)

  map_all("<Down>", function()
    move(state, 1)
  end)

  map_all("<Up>", function()
    move(state, -1)
  end)

  map_all("<C-n>", function()
    move(state, 1)
  end)

  map_all("<C-p>", function()
    move(state, -1)
  end)

  map(state.input_buf, "<BS>", function()
    backspace(state)
  end)

  map(state.input_buf, "<C-h>", function()
    backspace(state)
  end)

  map(state.input_buf, "<Space>", function()
    feed_query(state, " ")
  end)

  for i = 32, 126 do
    local ch = string.char(i)
    if ch ~= " " then
      map(state.input_buf, ch, function()
        feed_query(state, ch)
      end)
    end
  end

  render(state)
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
    prompt = "Files> ",
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
    prompt = "Buffers> ",
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
    prompt = "Oldfiles> ",
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
    prompt = "Quickfix> ",
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
