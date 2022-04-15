
local M = {}
--  69 %a   "test.lua"                     第 6 行
--  76 #h   "README.md"                    第 1 行
--  78  h   "init.lua"                     第 1 行
M.close_other_buf = function ()
  -- local cur_winnr = vim.fn.winnr()
  local cur_buf = vim.fn.bufnr('%')
  if cur_buf == -1 then
    return
  end
  -- local bf_no = vim.fn.winbufnr(cur_winnr)
  vim.fn.execute('bn')
  local next_buf = vim.fn.bufnr('%')
  -- print('cur_buf ' .. cur_buf)

  local count = 999;
  while next_buf ~= -1 and cur_buf ~= next_buf and count > 0 do
    -- print('next_buf ' .. next_buf)
    local bdel = 'bdel ' .. next_buf
    vim.fn.execute('bn')
    vim.fn.execute(bdel)
    next_buf = vim.fn.bufnr('%')
    count = count - 1
  end
end

M.close_other_bufline = function ()
  vim.fn.execute('BufferLineCloseLeft')
  vim.fn.execute('BufferLineCloseRight')
end

M.packer_lazy_load = function(plugin, timer)
   if plugin then
      timer = timer or 0
      vim.defer_fn(function()
         require("packer").loader(plugin)
      end, timer)
   end
end

return M
