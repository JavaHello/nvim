--- Generic floating-terminal launcher.
---
--- Example:
---   local Launcher = require("kide.code_agent")
---   local lazygit = Launcher.new({ command = { "lazygit" }, title = "Lazygit" })
---   lazygit:toggle()
---
--- The Codex-specific public functions at the end are kept for backwards compatibility.
local M = {}
local DEFAULT_TIMEOUT_MS, DEFAULT_SETTLE_MS = 8000, 300

---@class KideLauncherState
---@field buf? integer
---@field win? integer
---@field job? integer
---@field ready boolean
---@field pending string[]
---@field generation integer
---@field startup_timer? table
---@field settle_timer? table
---@field output_seen boolean

---@class KideLauncher
---@field options KideLauncherOptions
---@field state KideLauncherState
local Launcher = {}
Launcher.__index = Launcher

local function command_of(command)
  if type(command) == "string" then
    return { command }
  end
  if type(command) == "table" and #command > 0 then
    return vim.deepcopy(command)
  end
end

local function window_options(title)
  local width, height = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
  return {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    focusable = true,
    row = math.floor((vim.o.lines - height) * 0.5),
    col = math.floor((vim.o.columns - width) * 0.5),
    width = width,
    height = height,
    title = title,
    title_pos = "center",
  }
end

---@class KideLauncherOptions
---@field command string|string[] Command to launch (required).
---@field title? string Floating-window title.
---@field cwd? string Process working directory.
---@field ready_patterns? string[] Wait for one Lua pattern before flushing queued input.
---@field startup_timeout_ms? integer Ready-detection timeout.
---@field startup_settle_ms? integer Delay after initial output before considering ready.
---@field win_opts? table|fun(title: string): table Options for nvim_open_win.
---@field on_exit? fun(code: integer, signal: integer) Process-exit callback.

---@param opts KideLauncherOptions
---@return KideLauncher
function M.new(opts)
  assert(
    type(opts) == "table" and command_of(opts.command),
    "`command` must be a non-empty string or list"
  )
  return setmetatable({
    options = vim.deepcopy(opts),
    state = {
      buf = nil,
      win = nil,
      job = nil,
      ready = false,
      pending = {},
      generation = 0,
      startup_timer = nil,
      settle_timer = nil,
      output_seen = false,
    },
  }, Launcher)
end

function Launcher:is_running()
  local job = self.state.job
  return job and job > 0 and vim.fn.jobwait({ job }, 0)[1] == -1 or false
end

function Launcher:_stop_timer(name)
  local timer = self.state[name]
  if timer then
    timer:stop()
    timer:close()
    self.state[name] = nil
  end
end

function Launcher:_close_window(force)
  local win = self.state.win
  local closed = win
    and vim.api.nvim_win_is_valid(win)
    and pcall(vim.api.nvim_win_close, win, force or false)
  self.state.win = nil
  if closed then
    vim.schedule(function()
      pcall(function()
        vim.cmd("checktime")
      end)
    end)
  end
end

function Launcher:_reset()
  self:_stop_timer("startup_timer")
  self:_stop_timer("settle_timer")
  self:_close_window(true)
  if self.state.buf and vim.api.nvim_buf_is_valid(self.state.buf) then
    vim.api.nvim_buf_delete(self.state.buf, { force = true })
  end
  local state = self.state
  state.buf, state.job, state.ready, state.pending, state.output_seen = nil, nil, false, {}, false
  state.generation = state.generation + 1
end

function Launcher:close()
  self:_close_window(true)
end

function Launcher:_title()
  return self.options.title or command_of(self.options.command)[1]
end

function Launcher:_win_opts()
  local opts = self.options.win_opts
  if type(opts) == "function" then
    return opts(self:_title())
  end
  return opts and vim.deepcopy(opts) or window_options(self:_title())
end

function Launcher:_open_window()
  if self.state.buf and vim.api.nvim_buf_is_valid(self.state.buf) then
    self.state.win = vim.api.nvim_open_win(self.state.buf, true, self:_win_opts())
  end
end

function Launcher:_focus()
  if self.state.win and vim.api.nvim_win_is_valid(self.state.win) then
    vim.api.nvim_set_current_win(self.state.win)
    vim.cmd("startinsert!")
  end
end

function Launcher:_write(text)
  vim.fn.chansend(self.state.job, text)
  if not text:match("\n$") then
    vim.fn.chansend(self.state.job, "\n")
  end
end

function Launcher:_mark_ready()
  if not self:is_running() or self.state.ready then
    return
  end
  self.state.ready = true
  self:_stop_timer("startup_timer")
  self:_stop_timer("settle_timer")
  local pending = self.state.pending
  self.state.pending = {}
  for _, text in ipairs(pending) do
    self:_write(text)
  end
end

function Launcher:_buffer_is_ready()
  local patterns = self.options.ready_patterns
  if not patterns or #patterns == 0 then
    return true
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(self.state.buf, 0, -1, false)) do
    if line:match("%S") then
      self.state.output_seen = true
    end
    for _, pattern in ipairs(patterns) do
      if line:lower():match(pattern:lower()) then
        return true
      end
    end
  end
  return false
end

function Launcher:_watch_ready()
  local state, generation = self.state, self.state.generation
  if not self.options.ready_patterns or #self.options.ready_patterns == 0 then
    self:_mark_ready()
    return
  end
  vim.api.nvim_buf_attach(state.buf, false, {
    on_lines = function()
      if generation ~= state.generation or not self:is_running() or state.ready then
        return true
      end
      if self:_buffer_is_ready() then
        self:_mark_ready()
        return true
      end
      if state.output_seen then
        self:_stop_timer("settle_timer")
        state.settle_timer = vim.uv.new_timer()
        state.settle_timer:start(
          self.options.startup_settle_ms or DEFAULT_SETTLE_MS,
          0,
          vim.schedule_wrap(function()
            if
              generation == state.generation
              and self:is_running()
              and not state.ready
              and state.output_seen
            then
              self:_mark_ready()
            end
          end)
        )
      end
    end,
  })
  state.startup_timer = vim.uv.new_timer()
  state.startup_timer:start(
    self.options.startup_timeout_ms or DEFAULT_TIMEOUT_MS,
    0,
    vim.schedule_wrap(function()
      if generation == state.generation and self:is_running() and not state.ready then
        self:_mark_ready()
      end
    end)
  )
end

---@return boolean
function Launcher:start()
  if self:is_running() then
    return true
  end
  self:_reset()
  local state, command = self.state, command_of(self.options.command)
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].modified = false
  vim.b[state.buf].q_close = false
  pcall(require("kide").term_stl, state.buf, self:_title())
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = state.buf,
    callback = function()
      self:_close_window(false)
    end,
  })
  vim.api.nvim_create_autocmd(
    "TermOpen",
    { buffer = state.buf, command = "startinsert!", once = true }
  )
  self:_open_window()
  local ok, job = pcall(vim.fn.jobstart, command, {
    term = true,
    cwd = self.options.cwd,
    on_exit = function(_, code, signal)
      local callback = self.options.on_exit
      self:_reset()
      if callback then
        callback(code, signal)
      end
    end,
  })
  if not ok or job <= 0 then
    self:_reset()
    vim.notify(
      ("%s failed to start: %s"):format(self.options.title or command[1], tostring(job)),
      vim.log.levels.ERROR
    )
    return false
  end
  state.job = job
  self:_watch_ready()
  return true
end

---@return boolean
function Launcher:toggle()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  if self:is_running() then
    if self.state.win and vim.api.nvim_win_is_valid(self.state.win) then
      self:_close_window(true)
    else
      self:_open_window()
      self:_focus()
    end
    return true
  end
  if self:start() then
    self:_focus()
    return true
  end
  return false
end

---@param text string
---@param opt? { focus?: boolean }
---@return boolean
function Launcher:send(text, opt)
  opt = opt or {}
  if not text or text == "" then
    return false
  end
  if not self:is_running() and not self:start() then
    return false
  end
  if
    opt.focus ~= false and (not self.state.win or not vim.api.nvim_win_is_valid(self.state.win))
  then
    self:_open_window()
  end
  if opt.focus ~= false then
    self:_focus()
  end
  if self.state.ready then
    self:_write(text)
  else
    table.insert(self.state.pending, text)
  end
  return true
end

M.Launcher = Launcher
local codex = M.new({
  command = { "codex" },
  title = "Codex",
  ready_patterns = { "esc to toggle", "cwd:", "model:", "tokens" },
})
local opencode = M.new({ command = { "opencode" }, title = "OpenCode" })
M.current = nil

---@param bufnr? integer
---@return string
function M.buffer_path(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr or vim.api.nvim_get_current_buf())
  if filename == "" then
    return ""
  end
  local cwd = vim.uv.cwd()
  if not cwd or cwd == "" then
    return filename
  end
  local relative = vim.fn.fnamemodify(filename, ":.")
  if relative ~= "." and relative ~= filename and not relative:match("^%.%.") then
    return relative
  end
  local prefix = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
  return filename:sub(1, #prefix) == prefix and filename:sub(#prefix + 1) or filename
end

function M.send(text, opt)
  return M.current:send(text, opt)
end

local function _select_launcher()
  vim.ui.select({ "Codex", "OpenCode" }, { prompt = "Select code agent:" }, function(choice)
    print("Selected code agent:", choice)
    if choice == "Codex" then
      M.current = codex
    elseif choice == "OpenCode" then
      M.current = opencode
    end
    if M.current ~= nil then
      M.current:toggle()
    end
  end)
end

function M.toggle()
  if M.current == nil then
    _select_launcher()
  else
    M.current:toggle()
  end
end

function M.codex()
  M.current = codex
  M.current:toggle()
end

function M.opencode()
  M.current = opencode
  M.current:toggle()
end

---@param diagnostics vim.Diagnostic[]
---@param opt? { code?: string[], extra_prompt?: string, bufnr?: integer }
---@return string?
function M.build_fix_message(diagnostics, opt)
  opt = opt or {}
  if not diagnostics or vim.tbl_isempty(diagnostics) then
    return nil
  end
  local bufnr = opt.bufnr or vim.api.nvim_get_current_buf()
  local filename, filetype = M.buffer_path(bufnr), vim.bo[bufnr].filetype or "text"
  local need_code = not opt.code
  local message = { "请根据下面的 LSP/编译诊断直接修复代码。" }
  if opt.extra_prompt and opt.extra_prompt ~= "" then
    table.insert(message, "附加要求: " .. opt.extra_prompt)
  end
  if filename ~= "" then
    table.insert(message, "文件: " .. filename)
  end
  for _, diagnostic in ipairs(diagnostics) do
    local severity = diagnostic.severity == 1 and "ERROR"
      or diagnostic.severity == 2 and "WARN"
      or "INFO"
    table.insert(message, "")
    table.insert(message, "## " .. severity .. ": " .. (diagnostic.code or "Unknown Code"))
    table.insert(message, "- Source: " .. (diagnostic.source or "Unknown Source"))
    table.insert(
      message,
      ("- Range: %d:%d - %d:%d"):format(
        diagnostic.lnum + 1,
        diagnostic.col + 1,
        diagnostic.end_lnum + 1,
        diagnostic.end_col + 1
      )
    )
    local code = need_code
        and vim.api.nvim_buf_get_lines(bufnr, diagnostic.lnum, diagnostic.end_lnum + 1, false)
      or {}
    if #code > 0 then
      vim.list_extend(message, { "- Code Snippet", "```" .. filetype })
      vim.list_extend(message, code)
      table.insert(message, "```")
    end
    vim.list_extend(message, { "- Diagnostic Message", "```text" })
    vim.list_extend(message, vim.split(diagnostic.message or "No message provided", "\n"))
    table.insert(message, "```")
  end
  if opt.code and not vim.tbl_isempty(opt.code) then
    vim.list_extend(message, { "", "## Selected Code", "```" .. filetype })
    vim.list_extend(message, opt.code)
    table.insert(message, "```")
  end
  return table.concat(message, "\n")
end

function M.fix_diagnostics(opt)
  opt = opt or {}
  local bufnr = opt.bufnr or vim.api.nvim_get_current_buf()
  local diagnostics = opt.diagnostics
    or vim.diagnostic.get(bufnr, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if vim.tbl_isempty(diagnostics) then
    vim.notify("没有诊断信息", vim.log.levels.INFO)
    return false
  end
  local message = M.build_fix_message(diagnostics, opt)
  return message and M.send(message) or false
end

return M
