local utils = require("kide.core.utils")
local M = {}

local function delete_file(hf)
  local files = vim.fn.system("fd -I -H " .. hf .. "$")
  if files and files ~= "" then
    for file in string.gmatch(files, "[^\r\n]+") do
      vim.fn.system("rm -rf " .. file)
    end
    return files
  end
end

-- fd -I -H settings$ | xargs rm -rf
-- fd -I -H classpath$ | xargs rm -rf
-- fd -I -H project$ | xargs rm -rf
-- fd -I -H factorypath$ | xargs rm -rf
local function clean_jdtls()
  local del_files = delete_file("settings") or ""
  del_files = del_files .. (delete_file("classpath") or "")
  del_files = del_files .. (delete_file("project") or "")
  del_files = del_files .. (delete_file("factorypath") or "")
  vim.notify("delete: \n" .. del_files, vim.log.levels.INFO)
end

M.setup = function()
  if utils.is_mac or utils.is_linux then
    vim.api.nvim_create_user_command("CleanJdtls", function()
      clean_jdtls()
    end, {
      nargs = 0,
    })
  end
end
return M
