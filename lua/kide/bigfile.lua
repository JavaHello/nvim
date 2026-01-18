local M = {}
-- bigfile disable
function M.bigfile(buf)
  local max_filesize = 1024 * 1024 -- 1MB
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > max_filesize then
    return true
  end
  return false
end

return M
