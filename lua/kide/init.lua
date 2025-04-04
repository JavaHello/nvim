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
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", icon, " %#StatusLine#", title, " %#Comment#", usage })
  else
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", icon, " %#StatusLine#", title })
  end
end
function M.term_stl(buf, cmd)
  local cmd_0 = cmd[1]
  if cmd_0 == "curl" then
    M.set_buf_stl(buf, { " %#DiagnosticInfo#", "󰢩", " %#StatusLine#", "cURL" })
  elseif cmd_0 == "mvn" then
    M.set_buf_stl(buf, { " %#DiagnosticError#", "", " %#StatusLine#", "Maven (" .. table.concat(cmd, " ") .. ")" })
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

---清理全局状态
---@param id number stl id
---@param code number exit code
function M.clean_stl_status(id, code)
  M.stl_stop = true
  M.stl_timer:stop()
  require("kide.stl").exit_status(id, code)
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
