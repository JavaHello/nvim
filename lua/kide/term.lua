-- 使用 https://github.com/mfussenegger/dotfiles/blob/master/vim/dot-config/nvim/lua/me/term.lua
local api = vim.api

local M = {}

local job = nil
local termwin = nil
local repls = {
  python = "py",
  lua = "lua",
}

local function launch_term(cmd, opts)
  opts = opts or {}

  opts.term = true
  local path = vim.bo.path
  vim.cmd("belowright new")

  termwin = api.nvim_get_current_win()
  vim.bo.path = path
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  opts = vim.tbl_extend("error", opts, {
    on_exit = function()
      job = nil
    end,
  })
  job = vim.fn.jobstart(cmd, opts)
end

local function close_term()
  if not job then
    return
  end
  vim.fn.jobstop(job)
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

function M.toggle(cmd)
  if job then
    close_term()
  else
    cmd = cmd or (vim.env["SHELL"] or "sh")
    launch_term(cmd)
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
function M.input_run(last)
  if last then
    return M.toggle(M.last_input)
  end
  local ok, cmd = pcall(vim.fn.input, "CMD: ")
  if ok then
    if cmd == "" then
      M.toggle()
    else
      M.last_input = cmd
      M.toggle(cmd)
    end
  end
end

return M
