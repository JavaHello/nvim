local M = {}
--  69 %a   "test.lua"                     第 6 行
--  76 #h   "README.md"                    第 1 行
--  78  h   "init.lua"                     第 1 行
M.close_other_buf = function()
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

M.close_other_bufline = function()
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

M.is_upper = function(c)
  return c >= 65 and c <= 90
end

M.is_lower = function(c)
  return c >= 97 and c <= 122
end
M.char_size = function(c)
  local code = c;
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
  if word == '' or word == nil then
    return
  end
  if word:find('_') then
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
      f = false;
      if cf and i ~= 1 then
        table.insert(result, '_')
      end
    else
      f = true
    end
    local e = i + cs;
    table.insert(result, word:sub(i, e - 1))
    i = e
  end
  return table.concat(result, ''):upper()
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
    local e = i + cs;
    if cs == nil then
      return word
    end
    local cf = f;
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
  return table.concat(result, '')
end
M.camel_case_start = function(r, l1, l2)
  local word
  if r == 0 then
    word = vim.fn.expand('<cword>')
    local cw = M.camel_case(word)
    if cw then
      vim.fn.setreg('"', M.camel_case(word))
    end
  elseif l1 == l2 then
    word = vim.fn.getline('.')
    local ln1 = vim.fn.getpos("'<")
    local ln2 = vim.fn.getpos("'>")
    local cs = ln1[3]
    local ce = ln2[3]
    local ecs = M.char_size(word:byte(ce))
    if ecs ~= 1 then
      ce = ce + ecs - 1
    end
    word = word:sub(cs, ce)
    local reg_tmp = vim.fn.getreg('a')
    vim.fn.setreg('a', M.camel_case(word))
    vim.cmd('normal! gv"ap')
    vim.fn.setreg('a', reg_tmp)
  else
    vim.notify('请选择单行字符', vim.log.levels.WARN)
  end
end
M.test = function(a)
  print(a)
end
M.camel_case_init = function()
  vim.cmd [[
  " command! -complete=customlist,coreutils#cmdline#complete -nargs=* -bang -range
  command!  -nargs=* -range
  \ CamelCase
  \ lua require('core.utils').camel_case_start(<range>, <line1>, <line2>)
]]
end
-- print(M.camel_case("helloWorldAaAaAxC"))

M.format_range_operator = function()
  local old_func = vim.go.operatorfunc
  _G.op_func_formatting = function()
    local start = vim.api.nvim_buf_get_mark(0, '[')
    local finish = vim.api.nvim_buf_get_mark(0, ']')
    vim.lsp.buf.range_formatting({}, start, finish)
    vim.go.operatorfunc = old_func
    _G.op_func_formatting = nil
  end
  vim.go.operatorfunc = 'v:lua.op_func_formatting'
  vim.api.nvim_feedkeys('g@', 'n', false)
end



M.get_visual_selection = function()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end


-- 指定格式化 lsp_client
local format_lsp_mapping = {}
format_lsp_mapping["java"] = "jdt.ls"
format_lsp_mapping["lua"] = "sumneko_lua"

-- sql_formatter
format_lsp_mapping["sql"] = "null-ls"
-- prettier
format_lsp_mapping["javascript"] = "null-ls"
format_lsp_mapping["javascriptreact"] = "null-ls"
format_lsp_mapping["typescript"] = "null-ls"
format_lsp_mapping["typescriptreact"] = "null-ls"
format_lsp_mapping["vue"] = "null-ls"
format_lsp_mapping["css"] = "null-ls"
format_lsp_mapping["scss"] = "null-ls"
format_lsp_mapping["less"] = "null-ls"
format_lsp_mapping["html"] = "null-ls"
format_lsp_mapping["json"] = "null-ls"
format_lsp_mapping["jsonc"] = "null-ls"
format_lsp_mapping["yaml"] = "null-ls"
format_lsp_mapping["markdown"] = "null-ls"
format_lsp_mapping["graphql"] = "null-ls"
format_lsp_mapping["handlebars"] = "null-ls"

-- xmllint
format_lsp_mapping["xml"] = "null-ls"

-- taplo
format_lsp_mapping["toml"] = "null-ls"

-- shfmt
format_lsp_mapping["sh"] = "null-ls"

format_lsp_mapping["http"] = "null-ls"

M.filter_format_lsp_client = function(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local cn = format_lsp_mapping[filetype]
  return client.name == cn
end

return M
