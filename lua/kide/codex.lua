local M = {}
local state = {
  buf = nil,
  win = nil,
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
  close_window(true)
  clear_buffer()
  state.job = nil
end

function M.codex()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  if state.buf ~= nil then
    if state.win ~= nil then
      close_window(true)
      return
    end
    state.win = vim.api.nvim_open_win(state.buf, true, win_opts())
    return
  end

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
    return
  end

  if job_or_err <= 0 then
    reset_state()
    vim.notify("Codex failed to start: invalid job id", vim.log.levels.ERROR)
    return
  end

  state.job = job_or_err
end
return M
