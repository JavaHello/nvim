local M = {}
local STARTUP_TIMEOUT_MS = 8000
local STARTUP_SETTLE_MS = 300
local READY_PATTERNS = {
  "esc to toggle",
  "cwd:",
  "model:",
  "tokens",
}

local state = {
  buf = nil,
  win = nil,
  job = nil,
  ready = false,
  pending = {},
  startup_gen = 0,
  startup_timer = nil,
  settle_timer = nil,
  output_seen = false,
}

local function win_opts()
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.9)
  return {
    relative = "editor",
    style = "minimal",
    row = math.floor((lines - height) * 0.5),
    col = math.floor((columns - width) * 0.5),
    width = width,
    height = height,
    focusable = true,
    border = "rounded",
    title = "Codex",
    title_pos = "center",
  }
end

local function close_window(force)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, force or false)
  end
  state.win = nil
end

local function clear_buffer()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.buf = nil
end

local function reset_state()
  if state.startup_timer then
    state.startup_timer:stop()
    state.startup_timer:close()
    state.startup_timer = nil
  end
  if state.settle_timer then
    state.settle_timer:stop()
    state.settle_timer:close()
    state.settle_timer = nil
  end
  close_window(true)
  clear_buffer()
  state.job = nil
  state.ready = false
  state.pending = {}
  state.output_seen = false
  state.startup_gen = state.startup_gen + 1
end

local function is_job_running()
  if not state.job or state.job <= 0 then
    return false
  end
  return vim.fn.jobwait({ state.job }, 0)[1] == -1
end

local function mark_ready()
  if not is_job_running() or state.ready then
    return
  end
  state.ready = true
  if state.startup_timer then
    state.startup_timer:stop()
    state.startup_timer:close()
    state.startup_timer = nil
  end
  if state.settle_timer then
    state.settle_timer:stop()
    state.settle_timer:close()
    state.settle_timer = nil
  end

  local pending = state.pending
  state.pending = {}
  for _, text in ipairs(pending) do
    vim.fn.chansend(state.job, text)
    if not text:match("\n$") then
      vim.fn.chansend(state.job, "\n")
    end
  end
end

local function buffer_indicates_ready()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
  for _, line in ipairs(lines) do
    if line:match("%S") then
      state.output_seen = true
    end
    local lower = line:lower()
    for _, pattern in ipairs(READY_PATTERNS) do
      if lower:match(pattern) then
        return true
      end
    end
  end

  return false
end

local function arm_settle_timer(gen)
  if state.settle_timer then
    state.settle_timer:stop()
    state.settle_timer:close()
  end

  state.settle_timer = vim.loop.new_timer()
  state.settle_timer:start(STARTUP_SETTLE_MS, 0, vim.schedule_wrap(function()
    if gen ~= state.startup_gen or not is_job_running() or state.ready then
      return
    end
    if state.output_seen then
      mark_ready()
    end
  end))
end

local function start_ready_watch()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  local gen = state.startup_gen
  state.ready = false
  state.output_seen = false

  vim.api.nvim_buf_attach(state.buf, false, {
    on_lines = function()
      if gen ~= state.startup_gen or not is_job_running() or state.ready then
        return true
      end
      if buffer_indicates_ready() then
        mark_ready()
        return true
      end
      if state.output_seen then
        arm_settle_timer(gen)
      end
    end,
    on_detach = function()
      return true
    end,
  })

  state.startup_timer = vim.loop.new_timer()
  state.startup_timer:start(STARTUP_TIMEOUT_MS, 0, vim.schedule_wrap(function()
    if gen ~= state.startup_gen or not is_job_running() or state.ready then
      return
    end
    mark_ready()
  end))
end

local function open_window()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    state.win = vim.api.nvim_open_win(state.buf, true, win_opts())
  end
end

local function ensure_job()
  if is_job_running() then
    return true
  end
  reset_state()

  state.buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(state.buf, true, win_opts())
  vim.bo[state.buf].modified = false
  vim.b[state.buf].q_close = false

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = state.buf,
    callback = function()
      close_window(false)
    end,
  })
  vim.api.nvim_create_autocmd({ "TermOpen" }, {
    buffer = state.buf,
    command = "startinsert!",
    once = true,
  })

  local job_opts = {
    term = true,
    on_exit = function()
      reset_state()
    end,
  }

  local ok, job_or_err = pcall(vim.fn.jobstart, { "codex" }, job_opts)
  if not ok then
    reset_state()
    vim.notify(("Codex failed to start: %s"):format(job_or_err), vim.log.levels.ERROR)
    return false
  end

  if job_or_err <= 0 then
    reset_state()
    vim.notify("Codex failed to start: invalid job id", vim.log.levels.ERROR)
    return false
  end

  state.job = job_or_err
  start_ready_watch()
  return true
end

function M.codex()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  if is_job_running() and state.buf ~= nil then
    if state.win ~= nil then
      close_window(true)
      return
    end
    open_window()
    return
  end
  ensure_job()
end

function M.send(text, opt)
  opt = opt or {}
  if not text or text == "" then
    return false
  end
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  if not is_job_running() and not ensure_job() then
    vim.notify("Codex 启动失败", vim.log.levels.ERROR)
    return false
  end
  if opt.focus ~= false and (state.win == nil or not vim.api.nvim_win_is_valid(state.win)) then
    open_window()
  end
  if state.ready then
    vim.fn.chansend(state.job, text)
    if not text:match("\n$") then
      vim.fn.chansend(state.job, "\n")
    end
    return true
  end
  table.insert(state.pending, text)
  return true
end

return M
