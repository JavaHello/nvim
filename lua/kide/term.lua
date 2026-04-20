-- 使用 https://github.com/mfussenegger/dotfiles/blob/master/vim/dot-config/nvim/lua/me/term.lua
local api = vim.api
local bit = require("bit")

local M = {}

local job = nil
local termwin = nil
local repls = {
  python = "py",
  lua = "lua",
}
local sid

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

local function launch_term(cmd, opts)
  opts = opts or {}

  opts.term = true
  local path = vim.bo.path
  vim.cmd("belowright new")

  termwin = api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  -- vim.wo.winfixbuf = true
  require("kide").term_stl(bufnr, cmd)
  vim.keymap.set({ "n" }, "<CR>", open_file_under_cursor, { silent = true, buffer = bufnr })
  vim.bo.path = path
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  opts = vim.tbl_extend("error", opts, {
    on_exit = function(_, code, _)
      job = nil
      if sid then
        require("kide").clean_stl_status(sid, code)
      end
    end,
  })
  job = vim.fn.jobstart(cmd, opts)
end

local function close_term()
  if not job then
    return
  end
  vim.fn.jobstop(job)
  job = nil
  if termwin and api.nvim_win_is_valid(termwin) then
    -- avoid cannot close last window error
    pcall(api.nvim_win_close, termwin, true)
  end
  termwin = nil
end

function M.repl()
  local win = api.nvim_get_current_win()
  M.toggle(repls[vim.bo.filetype])
  api.nvim_set_current_win(win)
end

function M.toggle(cmd, opts)
  if cmd then
    sid = require("kide").timer_stl_status("")
  end
  if job then
    close_term()
  else
    cmd = cmd or (vim.env["SHELL"] or "sh")
    launch_term(cmd, opts)
  end
end

function M.run()
  local filepath = api.nvim_buf_get_name(0)
  local lines = api.nvim_buf_get_lines(0, 0, 1, true)
  ---@type string|string[]
  local cmd = filepath
  if not vim.startswith(lines[1], "#!/usr/bin/env") then
    local choice = vim.fn.confirm("File has no shebang, sure you want to execute it?", "&Yes\n&No")
    if choice ~= 1 then
      return
    end
  end
  local stat = vim.loop.fs_stat(filepath)
  if stat then
    local user_execute = tonumber("00100", 8)
    if bit.band(stat.mode, user_execute) ~= user_execute then
      local newmode = bit.bor(stat.mode, user_execute)
      vim.loop.fs_chmod(filepath, newmode)
    end
  end
  close_term()
  launch_term(cmd)
end

function M.send_line(line)
  if not job then
    return
  end
  vim.fn.chansend(job, line .. "\n")
end

M.last_input = nil
M.complete = function(arglead, cmdline, cursorpos)
  local line = cmdline or arglead or ""
  if vim.trim(line) == "Run" then
    if M.last_input and M.last_input ~= "" then
      return { M.last_input }
    end
    return {}
  end
  line = line:sub(4)

  local shell = vim.o.shell or vim.env.SHELL or ""
  local is_fish = vim.endswith(shell, "fish")

  local cursor = cursorpos or #line
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

return M
