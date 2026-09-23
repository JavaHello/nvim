-- 使用 https://github.com/mfussenegger/dotfiles/blob/master/vim/dot-config/nvim/lua/me/term.lua
--
-- 终端按「命令首词」实例化, 多个终端之间互不干扰:
--   require("kide.term").toggle()                     -- 切换交互 shell 终端
--   require("kide.term").toggle({ "go", "test" })     -- 切到/启动 go 终端
--   :Term list | :Term <key> | :Term restart <key> | :Term kill <key>
local api = vim.api

local M = {}

---交互 shell 终端的 key, 命令类实例一律带 CMD_PREFIX 前缀, 不会与之碰撞
local SHELL_KEY = "shell"
local CMD_PREFIX = "cmd:"

---@type table<string, kide.term.Term>
local registry = {}

local function open_file_under_cursor()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "t" then
    vim.cmd("stopinsert")
  end

  local file = vim.fn.expand("<cfile>")
  if file == nil or file == "" then
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  local fallback_win = nil
  local file_path = vim.fn.fnamemodify(file, ":p")

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= current_win and vim.api.nvim_win_is_valid(win) then
      local win_buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(win_buf) and vim.api.nvim_buf_get_name(win_buf) == file_path then
        vim.api.nvim_set_current_win(win)
        return
      end

      local cfg = vim.api.nvim_win_get_config(win)
      if fallback_win == nil and cfg.relative == "" and vim.bo[win_buf].buftype == "" then
        fallback_win = win
      end
    end
  end

  if fallback_win ~= nil then
    vim.api.nvim_set_current_win(fallback_win)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    return
  end

  vim.cmd("split " .. vim.fn.fnameescape(file))
end

---@class kide.term.Term
---@field key string 注册表键(shell 或 cmd:<命令首词>)
---@field label string 展示名(命令首词)
---@field cmd string|string[] 具体启动命令
---@field opts table jobstart 额外选项
---@field buf? integer 终端缓冲区
---@field win? integer 最后已知窗口(使用前必须重新校验)
---@field job? integer 运行中的 job
---@field sid? integer kide.stl 状态 id(shell 实例为 nil)
---@field generation integer 每次 launch/_stop 自增, 用于作废旧 job 的 on_exit
local Term = {}
Term.__index = Term

---@class kide.term.TermOpts
---@field key string
---@field label string
---@field cmd string|string[]
---@field opts? table

---@param opts kide.term.TermOpts
---@return kide.term.Term
function M.new(opts)
  return setmetatable({
    key = opts.key,
    label = opts.label,
    cmd = opts.cmd,
    opts = opts.opts or {},
    buf = nil,
    win = nil,
    job = nil,
    sid = nil,
    generation = 0,
  }, Term)
end

---@return boolean
function Term:is_running()
  local job = self.job
  return job ~= nil and job > 0 and vim.fn.jobwait({ job }, 0)[1] == -1 or false
end

---所有正在显示本终端缓冲区的窗口
---@return integer[]
function Term:_wins()
  if not self.buf or not api.nvim_buf_is_valid(self.buf) then
    return {}
  end
  return vim.fn.win_findbuf(self.buf)
end

---@return boolean
function Term:is_visible()
  return #self:_wins() > 0
end

---@return boolean
function Term:_focus()
  local wins = self:_wins()
  if #wins == 0 then
    return false
  end
  self.win = wins[1]
  api.nvim_set_current_win(self.win)
  if vim.bo[self.buf].buftype == "terminal" then
    vim.cmd("startinsert")
  end
  return true
end

---确保终端可见(已在显示则只聚焦, 不重复开窗), 不重启进程
---@return boolean
function Term:show()
  if not self.buf or not api.nvim_buf_is_valid(self.buf) then
    return false
  end
  if self:is_visible() then
    return self:_focus()
  end
  vim.cmd("belowright sbuffer " .. self.buf)
  self.win = api.nvim_get_current_win()
  return true
end

---隐藏终端窗口但保留终端进程/缓冲区
function Term:hide()
  for _, win in ipairs(self:_wins()) do
    -- avoid cannot close last window error
    pcall(api.nvim_win_close, win, true)
  end
  self.win = nil
end

---停止进程并销毁窗口/缓冲区
function Term:_stop()
  -- 先作废旧 job 的 on_exit, 避免它清理掉下一次启动的 job/sid
  self.generation = self.generation + 1
  if self.job then
    vim.fn.jobstop(self.job)
    self.job = nil
  end
  if self.sid then
    -- 主动杀掉进程, 状态栏上不留退出结果
    require("kide").drop_stl_status(self.sid)
    self.sid = nil
  end
  self:hide()
  if self.buf and api.nvim_buf_is_valid(self.buf) then
    pcall(api.nvim_buf_delete, self.buf, { force = true })
  end
  self.buf = nil
  self.win = nil
end

---停止进程并从注册表中移除
function Term:destroy()
  self:_stop()
  if registry[self.key] == self then
    registry[self.key] = nil
  end
end

---启动一个新的终端进程(每次都是新缓冲区)
---@param opts? table
function Term:_launch(opts)
  opts = vim.tbl_extend("force", {}, self.opts, opts or {})
  opts.term = true

  local path = vim.bo.path
  vim.cmd("belowright new")

  self.win = api.nvim_get_current_win()
  self.buf = api.nvim_get_current_buf()
  self.generation = self.generation + 1
  local generation = self.generation

  -- 交互 shell 长时间存活, 不挂状态栏 spinner
  if self.key ~= SHELL_KEY then
    -- "" 是 nerd-font 图标 U+EA85
    self.sid = require("kide").timer_stl_status("\238\170\133")
  end
  -- 状态栏失败不应该留下一个半成品终端
  pcall(require("kide").term_stl, self.buf, self.cmd)
  vim.keymap.set({ "n" }, "<CR>", open_file_under_cursor, { silent = true, buffer = self.buf })
  vim.bo.path = path
  vim.bo.buftype = "nofile"
  -- hide 保留终端进程, 关闭窗口不销毁会话
  vim.bo.bufhidden = "hide"
  vim.bo.buflisted = false
  vim.bo.swapfile = false

  local sid = self.sid
  opts.on_exit = function(_, code, _)
    if generation ~= self.generation then
      return
    end
    self.job, self.sid = nil, nil
    if sid then
      require("kide").clean_stl_status(sid, code)
    end
  end

  self.job = vim.fn.jobstart(self.cmd, opts)
  if not self:is_running() then
    self.job = nil -- job 可能在 jobstart 返回前就退出了
  end
end

---重启终端(先停旧进程再启动)
---@param opts? table
function Term:restart(opts)
  self:_stop()
  self:_launch(opts)
end

---运行中则切换显示/隐藏, 已退出则重启
---@param opts? table
function Term:toggle(opts)
  if self:is_running() then
    if self:is_visible() then
      self:hide()
    else
      self:show()
    end
    return
  end
  self:restart(opts)
end

---@param text string
function Term:send(text)
  if not self:is_running() then
    return
  end
  vim.fn.chansend(self.job, text)
end

---@return "running"|"exited"|"gone"
function Term:status()
  if self:is_running() then
    return "running"
  end
  if self.buf and api.nvim_buf_is_valid(self.buf) then
    return "exited"
  end
  return "gone"
end

---@return string
local function shell_cmd()
  if vim.env.SHELL and vim.env.SHELL ~= "" then
    return vim.env.SHELL
  end
  if vim.o.shell and vim.o.shell ~= "" then
    return vim.o.shell
  end
  return "sh"
end

---由命令推导实例 key / 展示名 / 具体命令
---@param cmd string|string[]|nil
---@return string? key, string? label, string|string[]? concrete
local function derive(cmd)
  if cmd == nil or (type(cmd) == "string" and vim.trim(cmd) == "") then
    return SHELL_KEY, "shell", shell_cmd()
  end
  if type(cmd) == "table" then
    local head = cmd[1]
    if type(head) == "string" and head ~= "" then
      return CMD_PREFIX .. head, head, cmd
    end
    return nil
  end
  if type(cmd) == "string" then
    local head = vim.trim(cmd):match("^%S+")
    return CMD_PREFIX .. head, head, cmd
  end
  return nil
end

---@param a string|string[]
---@param b string|string[]
---@return boolean
local function same_cmd(a, b)
  if type(a) ~= type(b) then
    return false
  end
  if type(a) == "table" then
    return table.concat(a, "\0") == table.concat(b, "\0")
  end
  return a == b
end

---丢弃缓冲区已失效且进程未运行的条目
local function prune()
  for key, inst in pairs(registry) do
    if inst:status() == "gone" then
      registry[key] = nil
    end
  end
end

---@param key string
---@param label string
---@param cmd string|string[]
---@param opts? table
---@return kide.term.Term
local function get_or_create(key, label, cmd, opts)
  local inst = registry[key]
  if not inst then
    inst = M.new({ key = key, label = label, cmd = cmd, opts = opts })
    registry[key] = inst
  end
  return inst
end

---切换/启动终端: 运行中只切换显示, 已退出则原地重启
---@param cmd? string|string[]
---@param opts? table
function M.toggle(cmd, opts)
  prune()
  local key, label, concrete = derive(cmd)
  if not key then
    vim.notify(("不支持的 cmd 类型: %s"):format(vim.inspect(cmd)), vim.log.levels.ERROR)
    return
  end
  local inst = get_or_create(key, label, concrete, opts)
  -- 同一首词的不同命令: 记下最新命令(已退出时重启即用新命令); 进程还在跑则只切换显示
  if key ~= SHELL_KEY and not same_cmd(inst.cmd, concrete) then
    inst.cmd = assert(concrete)
    if inst:is_running() then
      local msg =
        "%s 正在运行, 只切换显示; 新命令已记录, 可用 :Term restart %s 重启"
      vim.notify(msg:format(label, label), vim.log.levels.INFO)
    end
  end
  inst:toggle(opts)
end

---确保交互 shell 终端可见(隐藏则显示, 不存在则创建), 不重新生成已有终端
---@param opts? table
function M.open(opts)
  prune()
  local key, label, concrete = derive(nil)
  local inst = get_or_create(key, label, concrete, opts)
  if inst:is_running() then
    inst:show()
  else
    inst:restart(opts)
  end
end

---@param line string
function M.send_line(line)
  local inst = registry[SHELL_KEY]
  if inst then
    inst:send(line .. "\n")
  end
end

---@return kide.term.Term[]
function M.list()
  prune()
  local insts = {}
  for _, inst in pairs(registry) do
    table.insert(insts, inst)
  end
  table.sort(insts, function(a, b)
    return a.label < b.label
  end)
  return insts
end

---精确 key 优先, 其次按展示名查找
---@param name string
---@return kide.term.Term?
function M.get(name)
  prune()
  return registry[name] or registry[CMD_PREFIX .. name]
end

---@return string[]
function M.keys()
  local keys = {}
  for _, inst in ipairs(M.list()) do
    if not vim.tbl_contains(keys, inst.label) then
      table.insert(keys, inst.label)
    end
  end
  return keys
end

---@param bufnr integer
---@return kide.term.Term?
function M.owner(bufnr)
  for _, inst in pairs(registry) do
    if inst.buf == bufnr then
      return inst
    end
  end
end

---@param name string
---@param opts? table
---@return boolean
function M.restart(name, opts)
  local inst = M.get(name)
  if not inst then
    vim.notify(("终端不存在: %s"):format(name), vim.log.levels.WARN)
    return false
  end
  inst:restart(opts)
  return true
end

---@param name string
---@return boolean
function M.kill(name)
  local inst = M.get(name)
  if not inst then
    vim.notify(("终端不存在: %s"):format(name), vim.log.levels.WARN)
    return false
  end
  inst:destroy()
  return true
end

M.last_input = nil
M.complete = function(arglead, cmdline, cursorpos, opts)
  opts = opts or {}
  local prefix = opts.prefix
  local cmd = opts.cmd
  local last_input = opts.last_input or M.last_input
  local line = cmdline or arglead or ""
  if vim.trim(line) == prefix then
    if last_input and last_input ~= "" then
      return { last_input }
    end
    return {}
  end
  if cmd ~= nil then
    line = cmd .. line:sub(#cmd + 1)
  end
  if prefix ~= nil and vim.startswith(line, prefix) then
    line = line:sub(#prefix + 1)
  end

  local shell = vim.o.shell or vim.env.SHELL or ""
  local is_fish = vim.endswith(shell, "fish")

  local cursor = cursorpos or #line
  if prefix ~= nil and vim.startswith(cmdline or "", prefix) then
    cursor = cursor - #prefix
  end
  if cursor < 0 then
    cursor = 0
  end
  if cursor > 0 then
    line = line:sub(1, cursor)
  end

  local shell_items
  if is_fish then
    local ok, output = pcall(vim.fn.systemlist, {
      vim.o.shell,
      "-c",
      "complete -C " .. vim.fn.shellescape(line),
    })
    if ok and vim.v.shell_error == 0 then
      shell_items = {}
      for _, item in ipairs(output) do
        local text = vim.split(item, "\t", { plain = true })[1]
        if text and text ~= "" then
          table.insert(shell_items, text)
        end
      end
    else
      shell_items = {}
    end
  else
    shell_items = vim.fn.getcompletion(line, "shellcmdline")
  end

  return shell_items
end

---@param inst kide.term.Term
---@return string
local function describe(inst)
  local state = inst:status()
  if state == "running" then
    state = inst:is_visible() and "running" or "running(hidden)"
  end
  local cmd = type(inst.cmd) == "table" and table.concat(inst.cmd, " ") or inst.cmd
  local key = inst.label == inst.key and "" or (" [" .. inst.key .. "]")
  return ("%-14s%s  %-16s %s"):format(inst.label, key, state, cmd)
end

---当前缓冲区所属终端的展示名
---@return string?
local function current_name()
  local inst = M.owner(api.nvim_get_current_buf())
  return inst and inst.label
end

---注册 :Term 命令(list / <key> / restart <key> / kill <key>)
---注意 list / restart / kill 是保留子命令, 命令首词为它们时需用 :Term cmd:<首词> 访问
function M.setup()
  api.nvim_create_user_command("Term", function(opt)
    local args = vim.split(vim.trim(opt.args or ""), "%s+", { trimempty = true })
    local sub = args[1] or "list"

    if sub == "list" then
      local lines = { "终端实例:" }
      for _, inst in ipairs(M.list()) do
        table.insert(lines, "  " .. describe(inst))
      end
      if #lines == 1 then
        table.insert(lines, "  (无)")
      end
      vim.notify(table.concat(lines, "\n"))
      return
    end

    if sub == "restart" or sub == "kill" then
      local name = args[2] or current_name()
      if not name then
        vim.notify(
          (":Term %s 需要指定终端, 已知: %s"):format(sub, table.concat(M.keys(), ", ")),
          vim.log.levels.WARN
        )
        return
      end
      if sub == "restart" then
        M.restart(name)
      else
        M.kill(name)
      end
      return
    end

    local inst = M.get(sub)
    if not inst then
      vim.notify(
        ("终端不存在: %s, 已知: %s"):format(sub, table.concat(M.keys(), ", ")),
        vim.log.levels.WARN
      )
      return
    end
    inst:show()
  end, {
    desc = "终端实例管理",
    nargs = "*",
    complete = function(arglead, cmdline, _)
      local keys = M.keys()
      local words = vim.split(vim.trim(cmdline or ""), "%s+", { trimempty = true })
      if #words >= 2 and (words[2] == "restart" or words[2] == "kill") then
        return vim.tbl_filter(function(k)
          return vim.startswith(k, arglead)
        end, keys)
      end
      local candidates = { "list", "restart", "kill" }
      vim.list_extend(candidates, keys)
      return vim.tbl_filter(function(k)
        return vim.startswith(k, arglead)
      end, candidates)
    end,
  })
end

return M
