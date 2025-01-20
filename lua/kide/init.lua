local M = {
  stl_timer = vim.uv.new_timer(),
  stl_stop = false,
}
function M.clean_stl_status(code)
  if M.stl_timer then
    M.stl_stop = true
    M.stl_timer:stop()
  end
  require("kide.stl").exit_status(code)
end

---@param title string
function M.timer_stl_status(title)
  require("kide.stl").update_status(title)
  if M.stl_timer ~= nil then
    M.stl_stop = false
    M.stl_timer:stop()
    M.stl_timer:start(
      0,
      200,
      vim.schedule_wrap(function()
        if not M.stl_stop then
          require("kide.stl").update_status(title)
          vim.cmd.redrawstatus()
        end
      end)
    )
  end
end

return M
