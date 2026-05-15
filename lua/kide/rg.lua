local M = {}

local selection_ns = vim.api.nvim_create_namespace("kide_rg_live_grep")
local match_ns = vim.api.nvim_create_namespace("kide_rg_live_grep_matches")
local count_ns = vim.api.nvim_create_namespace("kide_rg_live_grep_count")
local preview_ns = vim.api.nvim_create_namespace("kide_rg_live_grep_preview")
local session = 0
local uv = vim.uv or vim.loop
local path_utils = require("kide.path")

local file_path_limit = 40

local function stopinsert()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
end

local function live_grep_opts()
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.8)
  local row = math.floor((lines - height) * 0.5)
  local col = math.floor((columns - width) * 0.5)
  local body_height = math.max(6, height - 2)
  local result_height = math.floor(body_height * 0.5)
  local preview_height = body_height - result_height

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
      title = "Live Grep",
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
      border = { "├", "─", "┤", "│", "┤", "─", "├", "│" },
      title = "Results",
      title_pos = "center",
    },
    preview = {
      relative = "editor",
      style = "minimal",
      row = row + result_height + 3,
      col = col,
      width = width,
      height = preview_height,
      focusable = true,
      border = { "├", "─", "┤", "│", "╯", "─", "╰", "│" },
    },
  }
end

local function set_scratch_options(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
end

local function set_result_lines(buf, lines)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

local function stop_job(state)
  if state.job and state.job > 0 then
    local job = state.job
    state.job = nil
    pcall(vim.fn.jobstop, job)
  end
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

local function detect_filetype(filename)
  if not vim.filetype or not vim.filetype.match then
    return ""
  end
  local ok, ft = pcall(vim.filetype.match, { filename = filename })
  if not ok or not ft then
    return ""
  end
  return ft
end

local function set_preview_syntax(state, filename)
  local buf = state.preview_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local ft = filename and detect_filetype(filename) or ""
  if state.preview_ft == ft then
    return
  end

  if state.preview_ft and state.preview_ft ~= "" then
    pcall(vim.treesitter.stop, buf)
  end
  if ft ~= "" then
    pcall(vim.treesitter.start, buf, ft)
  end
  vim.bo[buf].syntax = ft
  state.preview_ft = ft
end

local function update_input_count(state)
  if not state.input_buf or not vim.api.nvim_buf_is_valid(state.input_buf) then
    return
  end

  local suffix = state.truncated and "+" or ""
  local text = ("%d%s"):format(#state.items, suffix)

  vim.api.nvim_buf_clear_namespace(state.input_buf, count_ns, 0, -1)
  vim.api.nvim_buf_set_extmark(state.input_buf, count_ns, 0, 0, {
    virt_text = { { "  " .. text, "Comment" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
    priority = 100,
  })
end

local function apply_selection(state)
  if not state.result_buf or not vim.api.nvim_buf_is_valid(state.result_buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(state.result_buf, selection_ns, 0, -1)
  if vim.tbl_isempty(state.items) then
    if state.result_win and vim.api.nvim_win_is_valid(state.result_win) then
      vim.wo[state.result_win].cursorline = false
    end
    return
  end

  state.selected = math.max(1, math.min(state.selected, #state.items))
  if state.result_win and vim.api.nvim_win_is_valid(state.result_win) then
    vim.wo[state.result_win].cursorline = true
    pcall(vim.api.nvim_win_set_cursor, state.result_win, { state.selected, 0 })
  end
end

local function apply_preview_highlights(state)
  if not state.preview_buf or not vim.api.nvim_buf_is_valid(state.preview_buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(state.preview_buf, preview_ns, 0, -1)
  for row, prefix in ipairs(state.preview_prefixes or {}) do
    vim.api.nvim_buf_set_extmark(state.preview_buf, preview_ns, row - 1, 0, {
      virt_text = { { prefix, "LineNr" } },
      virt_text_pos = "inline",
      hl_mode = "combine",
      priority = 90,
    })
  end
  if state.preview_target_row then
    set_line_highlight(state.preview_buf, preview_ns, "CursorLine", state.preview_target_row - 1)
  end
  if state.preview_target_row then
    for _, match in ipairs(state.preview_matches or {}) do
      set_range_highlight(
        state.preview_buf,
        preview_ns,
        "Search",
        state.preview_target_row - 1,
        match.start,
        match.finish
      )
    end
  end
end

local function reset_preview_state(state)
  state.preview_prefixes = {}
  state.preview_matches = {}
  state.preview_target_row = nil
end

local function set_preview_error(state, request_id, lines)
  vim.schedule(function()
    if state.closed or request_id ~= state.preview_id then
      return
    end
    reset_preview_state(state)
    set_preview_syntax(state)
    set_result_lines(state.preview_buf, lines)
    apply_preview_highlights(state)
  end)
end

local function set_preview_entries(state, request_id, item, entries)
  vim.schedule(function()
    if state.closed or request_id ~= state.preview_id then
      return
    end

    reset_preview_state(state)
    if vim.tbl_isempty(entries) then
      set_preview_syntax(state)
      set_result_lines(state.preview_buf, { "" })
      apply_preview_highlights(state)
      return
    end

    local number_width = #tostring(entries[#entries].lnum)
    local lines = {}
    for _, entry in ipairs(entries) do
      local prefix = string.format("%" .. number_width .. "d  ", entry.lnum)
      table.insert(lines, entry.text)
      table.insert(state.preview_prefixes, prefix)
      if entry.lnum == item.lnum then
        state.preview_target_row = #lines
        state.preview_matches = item.matches or {}
      end
    end

    set_result_lines(state.preview_buf, lines)
    set_preview_syntax(state, item.file)
    apply_preview_highlights(state)
  end)
end

local function trim_ring(ring, limit)
  while #ring > limit do
    table.remove(ring, 1)
  end
end

local function read_preview_lines(state, request_id, item, preview_height)
  local desired_count = math.max(1, preview_height)
  local before = math.floor((desired_count - 1) * 0.5)
  local start_lnum = math.max(1, item.lnum - before)
  local end_lnum = start_lnum + desired_count - 1
  local before_ring = {}
  local entries = {}
  local current_lnum = 1
  local partial = ""
  local offset = 0
  local chunk_size = 64 * 1024

  local function stale()
    return state.closed or request_id ~= state.preview_id
  end

  local function close_fd(fd)
    if fd then
      pcall(uv.fs_close, fd, function() end)
    end
  end

  local function process_line(line)
    line = line:gsub("\r$", "")
    if current_lnum < start_lnum then
      table.insert(before_ring, { lnum = current_lnum, text = line })
      trim_ring(before_ring, desired_count)
    elseif current_lnum <= end_lnum then
      table.insert(entries, { lnum = current_lnum, text = line })
    end
    current_lnum = current_lnum + 1
  end

  local function finish(fd)
    close_fd(fd)
    if #entries < desired_count and #before_ring > 0 then
      local needed = math.min(desired_count - #entries, #before_ring)
      local fill = {}
      for i = #before_ring - needed + 1, #before_ring do
        table.insert(fill, before_ring[i])
      end
      vim.list_extend(fill, entries)
      entries = fill
    end
    set_preview_entries(state, request_id, item, entries)
  end

  uv.fs_open(item.file, "r", 438, function(open_err, fd)
    if stale() then
      close_fd(fd)
      return
    end
    if open_err or not fd then
      set_preview_error(state, request_id, { "Cannot read: " .. item.file })
      return
    end

    local function read_next()
      if stale() then
        close_fd(fd)
        return
      end
      if current_lnum > end_lnum and #entries >= desired_count then
        finish(fd)
        return
      end

      uv.fs_read(fd, chunk_size, offset, function(read_err, data)
        if stale() then
          close_fd(fd)
          return
        end
        if read_err then
          close_fd(fd)
          set_preview_error(state, request_id, { "Cannot read: " .. item.file })
          return
        end
        if not data or data == "" then
          if partial ~= "" then
            process_line(partial)
            partial = ""
          end
          finish(fd)
          return
        end

        offset = offset + #data
        data = partial .. data
        local from = 1
        while true do
          local nl = data:find("\n", from, true)
          if not nl then
            partial = data:sub(from)
            break
          end
          process_line(data:sub(from, nl - 1))
          from = nl + 1
          if current_lnum > end_lnum and #entries >= desired_count then
            partial = ""
            finish(fd)
            return
          end
        end
        read_next()
      end)
    end

    read_next()
  end)
end

local function preview_item_key(item)
  return ("%s:%d:%d:%s"):format(item.file, item.lnum, item.col or 0, item.text or "")
end

local function update_preview(state)
  if not state.preview_buf or not vim.api.nvim_buf_is_valid(state.preview_buf) then
    return
  end

  local item = state.items[state.selected]
  if not item then
    state.preview_id = (state.preview_id or 0) + 1
    state.preview_key = nil
    reset_preview_state(state)
    set_preview_syntax(state)
    set_result_lines(state.preview_buf, {})
    apply_preview_highlights(state)
    return
  end

  local key = preview_item_key(item)
  if state.preview_key == key then
    return
  end

  state.preview_id = (state.preview_id or 0) + 1
  state.preview_key = key
  local request_id = state.preview_id
  local preview_height = math.max(1, state.preview_height or 12)
  read_preview_lines(state, request_id, item, preview_height)
end

local function apply_highlights(state)
  if not state.result_buf or not vim.api.nvim_buf_is_valid(state.result_buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(state.result_buf, match_ns, 0, -1)
  for row, item in ipairs(state.items) do
    if item.file_len and item.prefix_len then
      set_range_highlight(state.result_buf, match_ns, "Directory", row - 1, 0, item.file_len)
      set_range_highlight(state.result_buf, match_ns, "LineNr", row - 1, item.file_len, item.prefix_len)
    end

    local prefix_len = item.prefix_len or 0
    for _, match in ipairs(item.matches or {}) do
      if match.finish > match.start then
        set_range_highlight(
          state.result_buf,
          match_ns,
          "Search",
          row - 1,
          prefix_len + match.start,
          prefix_len + match.finish
        )
      end
    end
  end
end

local function render(state)
  if state.closed then
    return
  end

  update_input_count(state)

  if not state.result_buf or not vim.api.nvim_buf_is_valid(state.result_buf) then
    return
  end

  local lines = state.display_lines
  if vim.tbl_isempty(lines) then
    if state.query == "" then
      lines = {}
    elseif state.running then
      lines = {}
    elseif not vim.tbl_isempty(state.stderr) then
      lines = { state.stderr[#state.stderr] }
    else
      lines = {}
    end
  end

  set_result_lines(state.result_buf, lines)
  apply_highlights(state)
  apply_selection(state)
  if not state.running then
    update_preview(state)
  end
end

local function schedule_render(state)
  if state.render_scheduled then
    return
  end
  state.render_scheduled = true
  vim.defer_fn(function()
    state.render_scheduled = false
    render(state)
  end, 40)
end

local function parse_json(line)
  local ok, item = pcall(vim.json.decode, line)
  if not ok or type(item) ~= "table" or item.type ~= "match" then
    return nil
  end

  local data = item.data or {}
  local result_path = data.path or {}
  local lines = data.lines or {}
  local submatches = data.submatches or {}
  local first_match = submatches[1] or {}
  local filename = result_path.text
  local lnum = data.line_number
  if not filename or not lnum then
    return nil
  end
  filename = filename:gsub("^%./", "")

  local text = lines.text or ""
  text = text:gsub("[\r\n]+$", "")
  local col = (first_match.start or 0) + 1
  local display_file = path_utils.shorten(filename, file_path_limit)
  local prefix = ("%s:%d:%d:"):format(display_file, lnum, col)
  local matches = {}
  for _, match in ipairs(submatches) do
    if match.start and match["end"] then
      table.insert(matches, {
        start = match.start,
        finish = match["end"],
      })
    end
  end

  return {
    file = filename,
    display_file = display_file,
    lnum = lnum,
    col = col,
    text = text,
    file_len = #display_file,
    prefix_len = #prefix,
    matches = matches,
    display = prefix .. text,
  }
end

local function append_result(state, line)
  if line == "" or #state.items >= state.limit then
    return
  end

  local item = parse_json(line)
  if not item then
    return
  end

  table.insert(state.items, item)
  table.insert(state.display_lines, item.display)
  if #state.items == 1 then
    state.selected = 1
  end
  if #state.items >= state.limit then
    state.truncated = true
    stop_job(state)
  end
  schedule_render(state)
end

local function collect_job_lines(data, partial, on_line)
  if not data or vim.tbl_isempty(data) then
    return partial or ""
  end

  data[1] = (partial or "") .. data[1]
  partial = table.remove(data)
  for _, line in ipairs(data) do
    on_line(line)
  end
  return partial or ""
end

local function current_query(state)
  if not state.input_buf or not vim.api.nvim_buf_is_valid(state.input_buf) then
    return ""
  end
  local line = vim.api.nvim_buf_get_lines(state.input_buf, 0, 1, false)[1] or ""
  return vim.trim(line)
end

local function start_search(state)
  if state.closed then
    return
  end

  local query = current_query(state)
  state.query = query
  state.search_id = state.search_id + 1
  local search_id = state.search_id
  stop_job(state)

  state.items = {}
  state.display_lines = {}
  state.stderr = {}
  state.stdout_partial = ""
  state.stderr_partial = ""
  state.selected = 1
  state.truncated = false
  state.preview_id = (state.preview_id or 0) + 1
  state.preview_key = nil
  state.running = query ~= ""
  render(state)

  if query == "" then
    return
  end

  local cmd = {
    "rg",
    "--json",
    "--color=never",
    "--smart-case",
    "--hidden",
    "--glob",
    "!.git/**",
    "--line-buffered",
    "--max-columns=500",
    "--max-columns-preview",
    "--",
    query,
    ".",
  }

  local job = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if state.closed or search_id ~= state.search_id then
        return
      end
      state.stdout_partial = collect_job_lines(data, state.stdout_partial, function(line)
        append_result(state, line)
      end)
    end,
    on_stderr = function(_, data)
      if state.closed or search_id ~= state.search_id then
        return
      end
      state.stderr_partial = collect_job_lines(data, state.stderr_partial, function(line)
        if line ~= "" then
          table.insert(state.stderr, line)
        end
      end)
    end,
    on_exit = function()
      vim.schedule(function()
        if state.closed or search_id ~= state.search_id then
          return
        end
        if state.stdout_partial ~= "" then
          append_result(state, state.stdout_partial)
          state.stdout_partial = ""
        end
        if state.stderr_partial ~= "" then
          table.insert(state.stderr, state.stderr_partial)
          state.stderr_partial = ""
        end
        state.running = false
        state.job = nil
        render(state)
      end)
    end,
  })

  if job <= 0 then
    state.running = false
    state.job = nil
    state.stderr = { "rg 启动失败" }
    render(state)
    return
  end
  state.job = job
end

local function schedule_search(state)
  state.debounce_id = state.debounce_id + 1
  local debounce_id = state.debounce_id
  vim.defer_fn(function()
    if state.closed or debounce_id ~= state.debounce_id then
      return
    end
    start_search(state)
  end, state.debounce)
end

local function close(state)
  if state.closed then
    return
  end
  stopinsert()
  state.closed = true
  stop_job(state)
  if state.group then
    pcall(vim.api.nvim_del_augroup_by_id, state.group)
  end
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    pcall(vim.api.nvim_win_close, state.input_win, true)
  end
  if state.result_win and vim.api.nvim_win_is_valid(state.result_win) then
    pcall(vim.api.nvim_win_close, state.result_win, true)
  end
  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    pcall(vim.api.nvim_win_close, state.preview_win, true)
  end
  if state.input_buf and vim.api.nvim_buf_is_valid(state.input_buf) then
    pcall(vim.api.nvim_buf_delete, state.input_buf, { force = true })
  end
  if state.result_buf and vim.api.nvim_buf_is_valid(state.result_buf) then
    pcall(vim.api.nvim_buf_delete, state.result_buf, { force = true })
  end
  if state.preview_buf and vim.api.nvim_buf_is_valid(state.preview_buf) then
    pcall(vim.api.nvim_buf_delete, state.preview_buf, { force = true })
  end
end

local function move_selection(state, delta)
  if vim.tbl_isempty(state.items) then
    return
  end
  local selected = math.max(1, math.min(state.selected + delta, #state.items))
  if selected == state.selected then
    return
  end
  state.selected = selected
  apply_selection(state)
  update_preview(state)
end

local function open_item(item)
  if not item then
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(item.file))
  pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max(item.col - 1, 0) })
  vim.cmd("normal! zv")
end

local function terminal_safe_text(text)
  text = tostring(text or "")
  text = text:gsub("\t", "    ")
  text = text:gsub("[%c]", " ")
  return text
end

local function truncate_text(text, max_width)
  if vim.fn.strdisplaywidth(text) <= max_width then
    return text
  end

  local width = math.max(1, max_width - 3)
  local chars = vim.fn.strchars(text)
  local truncated = vim.fn.strcharpart(text, 0, math.min(chars, width))
  while vim.fn.strdisplaywidth(truncated) > width and vim.fn.strchars(truncated) > 0 do
    truncated = vim.fn.strcharpart(truncated, 0, vim.fn.strchars(truncated) - 1)
  end
  return truncated .. "..."
end

local function fzy_item_line(item, index, max_width)
  local display_file = item.display_file or path_utils.shorten(item.file, file_path_limit)
  local line = ("%04d %s:%d:%d: %s"):format(index, display_file, item.lnum, item.col, terminal_safe_text(item.text))
  return truncate_text(line, max_width)
end

local function confirm_selection(state)
  local item = state.items[state.selected]
  if not item then
    return
  end

  stopinsert()
  close(state)
  open_item(item)
end

local function fzy_selection(state)
  if vim.tbl_isempty(state.items) then
    -- vim.notify("没有 rg 结果可交给 fzy", vim.log.levels.INFO)
    return
  end

  local lines = {}
  local item_by_line = {}
  local max_width = math.max(40, math.floor(vim.o.columns * 0.9) - 4)
  for index, item in ipairs(state.items) do
    local line = fzy_item_line(item, index, max_width)
    table.insert(lines, line)
    item_by_line[line] = item
  end

  stopinsert()
  close(state)
  require("kide.fzy").select(lines, {
    title = "Live Grep Results",
    empty_message = "没有 rg 结果",
    on_choice = function(choice)
      open_item(item_by_line[choice])
    end,
  })
end

local function focus_input(state, insert)
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_set_current_win(state.input_win)
    if insert then
      vim.cmd("startinsert!")
    end
  end
end

local function map(state, buf, mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { buffer = buf, noremap = true, silent = true, nowait = true })
end

function M.live_grep(opts)
  opts = opts or {}
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("rg 未安装或不在 PATH 中", vim.log.levels.WARN)
    return
  end

  stopinsert()
  session = session + 1

  local state = {
    id = session,
    query = vim.trim(opts.query or ""),
    items = {},
    display_lines = {},
    stderr = {},
    selected = 1,
    search_id = 0,
    debounce_id = 0,
    debounce = opts.debounce or 150,
    limit = opts.limit or 1000,
    running = false,
    closed = false,
  }

  local opts_layout = live_grep_opts()
  state.input_buf = vim.api.nvim_create_buf(false, true)
  state.result_buf = vim.api.nvim_create_buf(false, true)
  state.preview_buf = vim.api.nvim_create_buf(false, true)
  set_scratch_options(state.input_buf)
  set_scratch_options(state.result_buf)
  set_scratch_options(state.preview_buf)
  vim.bo[state.result_buf].modifiable = false
  vim.bo[state.result_buf].filetype = "grep"
  vim.bo[state.preview_buf].modifiable = false

  state.input_win = vim.api.nvim_open_win(state.input_buf, true, opts_layout.input)
  state.result_win = vim.api.nvim_open_win(state.result_buf, false, opts_layout.result)
  state.preview_win = vim.api.nvim_open_win(state.preview_buf, false, opts_layout.preview)
  state.preview_height = opts_layout.preview.height
  vim.wo[state.input_win].number = false
  vim.wo[state.input_win].relativenumber = false
  vim.wo[state.result_win].number = false
  vim.wo[state.result_win].relativenumber = false
  vim.wo[state.result_win].wrap = false
  vim.wo[state.result_win].cursorline = true
  vim.wo[state.preview_win].number = false
  vim.wo[state.preview_win].relativenumber = false
  vim.wo[state.preview_win].wrap = false
  vim.wo[state.preview_win].cursorline = false

  vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { state.query })
  vim.api.nvim_win_set_cursor(state.input_win, { 1, #state.query })

  state.group = vim.api.nvim_create_augroup("kide-rg-live-grep-" .. state.id, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = state.group,
    buffer = state.input_buf,
    callback = function()
      schedule_search(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = state.input_buf,
    callback = function()
      close(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = state.result_buf,
    callback = function()
      close(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = state.preview_buf,
    callback = function()
      close(state)
    end,
  })

  map(state, state.input_buf, "n", "q", function()
    close(state)
  end)
  map(state, state.input_buf, "n", "<ESC>", function()
    close(state)
  end)
  map(state, state.input_buf, { "i", "n" }, "<CR>", function()
    confirm_selection(state)
  end)
  map(state, state.input_buf, { "i", "n" }, "<C-c>", function()
    close(state)
  end)
  map(state, state.input_buf, { "i", "n" }, "<Down>", function()
    move_selection(state, 1)
  end)
  map(state, state.input_buf, { "i", "n" }, "<Up>", function()
    move_selection(state, -1)
  end)
  map(state, state.input_buf, "n", "j", function()
    move_selection(state, 1)
  end)
  map(state, state.input_buf, "n", "k", function()
    move_selection(state, -1)
  end)
  map(state, state.input_buf, { "i", "n" }, "<C-n>", function()
    move_selection(state, 1)
  end)
  map(state, state.input_buf, { "i", "n" }, "<C-p>", function()
    move_selection(state, -1)
  end)
  map(state, state.input_buf, { "i", "n" }, "<C-g>", function()
    fzy_selection(state)
  end)

  map(state, state.result_buf, "n", "q", function()
    close(state)
  end)
  map(state, state.result_buf, "n", "<CR>", function()
    confirm_selection(state)
  end)
  map(state, state.result_buf, "n", "i", function()
    focus_input(state, true)
  end)
  map(state, state.result_buf, "n", "/", function()
    focus_input(state, true)
  end)
  map(state, state.result_buf, "n", "j", function()
    move_selection(state, 1)
  end)
  map(state, state.result_buf, "n", "k", function()
    move_selection(state, -1)
  end)
  map(state, state.result_buf, "n", "<Down>", function()
    move_selection(state, 1)
  end)
  map(state, state.result_buf, "n", "<Up>", function()
    move_selection(state, -1)
  end)
  map(state, state.result_buf, "n", "<C-n>", function()
    move_selection(state, 1)
  end)
  map(state, state.result_buf, "n", "<C-p>", function()
    move_selection(state, -1)
  end)
  map(state, state.result_buf, "n", "<C-g>", function()
    fzy_selection(state)
  end)
  map(state, state.preview_buf, "n", "q", function()
    close(state)
  end)
  map(state, state.preview_buf, "n", "<CR>", function()
    confirm_selection(state)
  end)
  map(state, state.preview_buf, "n", "i", function()
    focus_input(state, true)
  end)
  map(state, state.preview_buf, "n", "/", function()
    focus_input(state, true)
  end)
  map(state, state.preview_buf, "n", "j", function()
    move_selection(state, 1)
  end)
  map(state, state.preview_buf, "n", "k", function()
    move_selection(state, -1)
  end)
  map(state, state.preview_buf, "n", "<C-n>", function()
    move_selection(state, 1)
  end)
  map(state, state.preview_buf, "n", "<C-p>", function()
    move_selection(state, -1)
  end)
  map(state, state.preview_buf, "n", "<C-g>", function()
    fzy_selection(state)
  end)

  render(state)
  schedule_search(state)
  focus_input(state, true)
end

return M
