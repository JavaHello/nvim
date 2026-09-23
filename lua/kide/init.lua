local M = {
  stl_timer = vim.uv.new_timer(),
  stl_stop = false,
}

function M.set_buf_stl(buf, stl)
  vim.b[buf].stl = stl
  vim.cmd.redrawstatus()
end

function M.gpt_stl(buf, icon, title, usage)
  if usage then
    M.set_buf_stl(
      buf,
      { " %#DiagnosticInfo#", icon, " %#StatusLine#", title, " %#Comment#", usage }
    )
  else
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", icon, " %#StatusLine#", title })
  end
end

function M.term_stl(buf, cmd)
  local cmd_type = type(cmd)
  local cmd_0
  if cmd_type == "table" then
    cmd_0 = cmd[1]
  elseif cmd_type == "string" then
    cmd_0 = cmd
  else
    vim.notify("不支持的 cmd 类型", vim.log.levels.ERROR)
    return
  end
  -- 字符串命令时 cmd 不是表, table.concat 会报错
  local full = cmd_type == "table" and table.concat(cmd, " ") or cmd
  if cmd_0 == "curl" then
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", "󰢩", " %#StatusLine#", "cURL" })
  elseif cmd_0 == "mvn" then
    M.set_buf_stl(buf, { " %#DiagnosticError#", "", " %#StatusLine#", "Maven (" .. full .. ")" })
  elseif cmd_0 == "Codex" then
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", "", " %#StatusLine#", "Codex" })
  else
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", "", " %#StatusLine#", cmd_0 })
  end
end

function M.lsp_stl(message)
  require("kide.stl").set_lsp_status(message)
  vim.cmd.redrawstatus()
  M.stl_timer:stop()
  M.stl_timer:start(
    500,
    0,
    vim.schedule_wrap(function()
      require("kide.stl").set_lsp_status(nil)
      vim.cmd.redrawstatus()
    end)
  )
end

---停掉重绘定时器, 但只在没有其它 pending 状态时(否则它们的 spinner 会卡住)
local function stop_stl_timer_if_idle()
  if not require("kide.stl").has_pending() then
    M.stl_stop = true
    M.stl_timer:stop()
  end
end

---清理全局状态
---@param id number stl id
---@param code number exit code
function M.clean_stl_status(id, code)
  -- exit_status 会把该状态标记为已结束, 必须先调用再判断是否还有其它 pending
  require("kide.stl").exit_status(id, code)
  stop_stl_timer_if_idle()
end

---丢弃状态(进程被主动结束/重启时用, 不留退出结果)
---@param id number stl id
function M.drop_stl_status(id)
  require("kide.stl").remove_status(id)
  stop_stl_timer_if_idle()
end

---@param title string
---@param buf? number
function M.timer_stl_status(title, buf)
  local id = require("kide.stl").new_status(title)
  M.stl_stop = false
  M.stl_timer:stop()
  M.stl_timer:start(
    0,
    200,
    vim.schedule_wrap(function()
      if not M.stl_stop then
        vim.cmd.redrawstatus()
      end
    end)
  )
  return id
end

return M
