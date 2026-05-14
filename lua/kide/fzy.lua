local M = {}

local function stopinsert()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
end

local function float_opts(title)
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.8)
  return {
    relative = "editor",
    style = "minimal",
    row = math.floor((lines - height) * 0.5),
    col = math.floor((columns - width) * 0.5),
    width = width,
    height = height,
    focusable = true,
    border = "rounded",
    title = title,
    title_pos = "center",
  }
end

local function shellescape(value)
  return vim.fn.shellescape(value)
end

local function fzy_command(opts)
  local args = {
    "fzy",
    "--prompt",
    opts.prompt or "> ",
    "--lines",
    tostring(math.max(10, opts.lines or math.floor(vim.o.lines * 0.75))),
    "--show-info",
  }
  if opts.query and opts.query ~= "" then
    vim.list_extend(args, { "--query", opts.query })
  end
  return table.concat(vim.tbl_map(shellescape, args), " ")
end

local function cleanup(state)
  for _, file in ipairs(state.tempfiles or {}) do
    if file and file ~= "" then
      vim.fn.delete(file)
    end
  end
end

local function close_window(state)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
end

local function startinsert(state)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    vim.cmd("startinsert!")
  end
end

local function run(source_cmd, opts)
  opts = opts or {}
  if vim.fn.executable("fzy") ~= 1 then
    cleanup({ tempfiles = opts.tempfiles })
    vim.notify("fzy 未安装或不在 PATH 中", vim.log.levels.WARN)
    return
  end

  stopinsert()

  local state = {
    chooserfile = vim.fn.tempname(),
    tempfiles = vim.deepcopy(opts.tempfiles or {}),
  }
  table.insert(state.tempfiles, state.chooserfile)

  local title = opts.title or "Fzy"
  local win_opts = float_opts(title)
  state.buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(state.buf, true, win_opts)
  vim.bo[state.buf].modified = false

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = state.buf,
    once = true,
    callback = function()
      if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        vim.api.nvim_buf_delete(state.buf, { force = true })
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    buffer = state.buf,
    callback = function()
      startinsert(state)
    end,
    once = true,
  })

  local command = ("%s | %s > %s"):format(
    source_cmd,
    fzy_command({
      prompt = opts.prompt,
      query = opts.query,
      lines = win_opts.height - 2,
    }),
    shellescape(state.chooserfile)
  )

  local ok, job_or_err = pcall(vim.fn.jobstart, { vim.o.shell, vim.o.shellcmdflag, command }, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        close_window(state)
        local choice = nil
        if vim.fn.filereadable(state.chooserfile) == 1 then
          choice = vim.fn.readfile(state.chooserfile)[1]
        end
        cleanup(state)
        if choice and choice ~= "" and opts.on_choice then
          opts.on_choice(choice)
        end
      end)
    end,
  })
  if not ok then
    close_window(state)
    cleanup(state)
    vim.notify(("fzy 启动失败: %s"):format(job_or_err), vim.log.levels.ERROR)
    return
  end
  if not job_or_err or job_or_err <= 0 then
    close_window(state)
    cleanup(state)
    vim.notify("fzy 启动失败: invalid job id", vim.log.levels.ERROR)
    return
  end
  vim.defer_fn(function()
    startinsert(state)
  end, 20)
end

local function run_lines(lines, opts)
  opts = opts or {}
  if vim.tbl_isempty(lines) then
    vim.notify(opts.empty_message or "没有可供 fzy 查找的内容", vim.log.levels.INFO)
    return
  end

  local inputfile = vim.fn.tempname()
  vim.fn.writefile(lines, inputfile)
  local source_cmd = "cat " .. shellescape(inputfile)
  local tempfiles = vim.deepcopy(opts.tempfiles or {})
  table.insert(tempfiles, inputfile)
  run(
    source_cmd,
    vim.tbl_extend("force", opts, {
      tempfiles = tempfiles,
    })
  )
end

local function open_file(filename, open)
  if not filename or filename == "" then
    return
  end
  vim.cmd((open or "edit") .. " " .. vim.fn.fnameescape(filename))
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

function M.files(opts)
  opts = opts or {}
  run(file_source(), {
    title = "Files",
    prompt = "Files> ",
    query = opts.query,
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
          ("%d\t%s:%d:%d\t%s"):format(idx, vim.fn.fnamemodify(filename, ":~:."), item.lnum or 1, item.col or 1, text)
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
