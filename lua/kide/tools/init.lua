local M = {}
--  69 %a   "test.lua"                     第 6 行
--  76 #h   "README.md"                    第 1 行
--  78  h   "init.lua"                     第 1 行
M.close_other_buf = function()
  -- local cur_winnr = vim.fn.winnr()
  local cur_buf = vim.fn.bufnr("%")
  if cur_buf == -1 then
    return
  end
  -- local bf_no = vim.fn.winbufnr(cur_winnr)
  vim.fn.execute("bn")
  local next_buf = vim.fn.bufnr("%")
  -- print('cur_buf ' .. cur_buf)

  local count = 999
  while next_buf ~= -1 and cur_buf ~= next_buf and count > 0 do
    -- print('next_buf ' .. next_buf)
    local bdel = "bdel " .. next_buf
    vim.fn.execute("bn")
    vim.fn.execute(bdel)
    next_buf = vim.fn.bufnr("%")
    count = count - 1
  end
end

M.is_upper = function(c)
  return c >= 65 and c <= 90
end

M.is_lower = function(c)
  return c >= 97 and c <= 122
end
M.char_size = function(c)
  local code = c
  if code < 127 then
    return 1
  elseif code <= 223 then
    return 2
  elseif code <= 239 then
    return 3
  elseif code <= 247 then
    return 4
  end
  return nil
end

M.camel_case = function(word)
  if word == "" or word == nil then
    return
  end
  if word:find("_") then
    return M.camel_case_c(word)
  else
    return M.camel_case_u(word)
  end
end
M.camel_case_u = function(word)
  local result = {}
  local len = word:len()
  local i = 1
  local f = true
  while i <= len do
    local c = word:byte(i)
    local cs = M.char_size(c)
    local cf = f
    if cs == nil then
      return word
    end
    if cs == 1 and M.is_upper(c) then
      f = false
      if cf and i ~= 1 then
        table.insert(result, "_")
      end
    else
      f = true
    end
    local e = i + cs
    table.insert(result, word:sub(i, e - 1))
    i = e
  end
  return table.concat(result, ""):upper()
end
M.camel_case_c = function(word)
  local w = word:lower()
  local result = {}
  local sc = 95
  local f = false
  local len = word:len()
  local i = 1
  while i <= len do
    local c = w:byte(i)
    local cs = M.char_size(c)
    local e = i + cs
    if cs == nil then
      return word
    end
    local cf = f
    if f then
      f = false
    end
    if c == sc then
      f = true
    else
      if cs == 1 and cf then
        table.insert(result, string.char(c):upper())
      else
        table.insert(result, w:sub(i, e - 1))
      end
    end
    i = e
  end
  return table.concat(result, "")
end
M.camel_case_start = function(r, l1, l2)
  local word
  if r == 0 then
    word = vim.fn.expand("<cword>")
    local cw = M.camel_case(word)
    if cw then
      vim.fn.setreg('"', M.camel_case(word))
    end
  elseif l1 == l2 then
    word = vim.fn.getline(".")
    local ln1 = vim.fn.getpos("'<")
    local ln2 = vim.fn.getpos("'>")
    local cs = ln1[3]
    local ce = ln2[3]
    local ecs = M.char_size(word:byte(ce))
    if ecs ~= 1 then
      ce = ce + ecs - 1
    end
    word = word:sub(cs, ce)
    local reg_tmp = vim.fn.getreg("a")
    vim.fn.setreg("a", M.camel_case(word))
    vim.cmd('normal! gv"ap')
    vim.fn.setreg("a", reg_tmp)
  else
    vim.notify("请选择单行字符", vim.log.levels.WARN)
  end
end
M.test = function(a)
  print(a)
end
M.camel_case_init = function()
  vim.api.nvim_create_user_command("CamelCase", function(o)
    require("kide.tools").camel_case_start(o.range, o.line1, o.line2)
  end, { range = 0, nargs = 0 })
end
-- print(M.camel_case("helloWorldAaAaAxC"))

-- see https://github.com/nvim-pack/nvim-spectre/blob/master/lua/spectre/utils.lua#L120
---@return string[]
M.get_visual_selection = function(mode)
  mode = mode or vim.fn.visualmode()
  --参考 @phanium  @linrongbin  @skywind3000 提供的方法。
  -- https://github.com/skywind3000/vim/blob/master/autoload/asclib/compat.vim
  return vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = mode })
end

M.run_cmd = function(cmd)
  return vim.fn.system(cmd)
end

M.Windows = "Windows"
M.Linux = "Linux"
M.Mac = "Mac"

M.os_type = function()
  local has = vim.fn.has
  local t = M.Linux
  if has("win32") == 1 or has("win64") == 1 then
    t = M.Windows
  elseif has("mac") == 1 then
    t = M.Mac
  end
  return t
end

M.is_win = M.os_type() == M.Windows
M.is_linux = M.os_type() == M.Linux
M.is_mac = M.os_type() == M.Mac

--- complete
---@param opt {model:"single"|"multiple"}
M.command_args_complete = function(complete, opt)
  opt = opt or {}
  if complete ~= nil then
    return function(_, cmd_line, _)
      if opt.model == "multiple" then
        local args = vim.split(cmd_line, " ")
        return vim.tbl_filter(function(item)
          return not vim.tbl_contains(args, item)
        end, complete)
      elseif opt.model == "single" then
        local args = vim.split(cmd_line, " ")
        for _, value in ipairs(args) do
          if vim.tbl_contains(complete, value) then
            return {}
          end
        end
        return complete
      else
        return complete
      end
    end
  end
end

M.open_fn = function(file)
  local cmd
  if M.is_linux then
    cmd = "xdg-open"
  elseif M.is_mac then
    cmd = "open"
  elseif M.is_win then
    cmd = "start"
  end
  vim.fn.system(string.format("%s %s", cmd, file))
end

M.tmpdir = function()
  if M.is_win then
    return os.getenv("TEMP")
  else
    return "/tmp"
  end
end

M.tmpdir_file = function(file)
  return M.tmpdir() .. "/" .. file
end

M.java_bin = function()
  local java_home = vim.env["JAVA_HOME"]
  if java_home then
    return java_home .. "/bin/java"
  end
  return "java"
end

-- URL safe base64 --> standard base64
M.base64_url_safe_to_std = function(msg)
  if string.match(msg, "-") then
    msg = string.gsub(msg, "-", "+")
  end
  if string.match(msg, "_") then
    msg = string.gsub(msg, "_", "/")
  end
  if not vim.endswith(msg, "=") then
    local padding = #msg % 4
    if padding > 0 then
      msg = msg .. string.rep("=", 4 - padding)
    end
  end
  return msg
end

M.base64_url_safe = function(msg)
  return M.base64_std_to_url_safe(vim.base64.encode(msg))
end

M.base64_std_to_url_safe = function(msg)
  if string.match(msg, "+") then
    msg = string.gsub(msg, "+", "-")
  end
  if string.match(msg, "/") then
    msg = string.gsub(msg, "/", "_")
  end
  if string.match(msg, "=") then
    msg = string.gsub(msg, "=", "")
  end
  return msg
end

return M
