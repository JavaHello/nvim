local M = {}
---@class kide.stl.Status
---@field index number
---@field buf? number
---@field code? number
---@field code_msg? string
---@field title? string

local glob_progress = { "   ", "  ", " ", "" }

local glob_idx = 0

local glob_stl = {}

function M.new_status(title, buf, bg_proc)
  glob_idx = glob_idx + 1
  ---@type kide.stl.Status
  local stl = {
    id = glob_idx,
    index = 0,
    buf = buf,
    bg_proc = bg_proc,
    code = nil,
    code_msg = nil,
    title = title,
  }
  glob_stl[glob_idx] = stl
  return stl.id
end

local function next_status()
  local stl_bar = {}
  for _, cstl in pairs(glob_stl) do
    if cstl.code then
      vim.list_extend(stl_bar, {
        " %#DiagnosticWarn#",
        cstl.title,
      })
      if cstl.code == 0 then
        vim.list_extend(stl_bar, { " %#DiagnosticOk#", cstl.code_msg })
      else
        vim.list_extend(stl_bar, { " %#DiagnosticError#", cstl.code_msg })
      end
    else
      if cstl.index >= #glob_progress then
        cstl.index = 0
      end
      cstl.index = cstl.index + 1
      vim.list_extend(stl_bar, {
        " %#DiagnosticWarn#",
        cstl.title,
        " ",
        glob_progress[cstl.index],
      })
    end
  end
  return stl_bar
end

local function buf_status()
  return vim.b[0].stl
end

local _lsp_status = nil
function M.set_lsp_status(message)
  _lsp_status = message
end
local function lsp_status()
  return _lsp_status
end

function M.exit_status(id, code)
  local cstl = glob_stl[id]
  if not cstl then
    return
  end
  if code then
    cstl.code = code
    if code == 0 then
      cstl.code_msg = "SUCCESS"
    else
      cstl.code_msg = "FAILED"
    end
    vim.defer_fn(function()
      glob_stl[id] = nil
    end, 2000)
  end
  vim.cmd.redrawstatus()
end

-- 参考 https://github.com/mfussenegger/dotfiles
function M.statusline()
  local parts = {
    "%<",
  }
  local bstl = buf_status()
  local lspstatus = lsp_status()
  if bstl then
    if type(bstl) == "table" then
      vim.list_extend(parts, bstl)
    else
      table.insert(parts, bstl)
    end
  elseif lspstatus then
    vim.list_extend(parts, { "%#DiagnosticInfo#", lspstatus })
  else
    local git = M.git_status()
    if git then
      table.insert(parts, " %#DiagnosticError# %#StatusLine#" .. git.head)
      if git.added and git.added > 0 then
        vim.list_extend(parts, { " %#Added# ", tostring(git.added) })
      end
      if git.removed and git.removed > 0 then
        vim.list_extend(parts, { " %#Removed#󰍵 ", tostring(git.removed) })
      end
      if git.changed and git.changed > 0 then
        vim.list_extend(parts, { " %#Changed# ", tostring(git.changed) })
      end
    end

    local fstatus = M.file()
    vim.list_extend(parts, fstatus)

    local counts = vim.diagnostic.count(0, { severity = { min = vim.diagnostic.severity.WARN } })
    local num_errors = counts[vim.diagnostic.severity.ERROR] or 0
    local num_warnings = counts[vim.diagnostic.severity.WARN] or 0
    table.insert(parts, " %#DiagnosticWarn#%r%m")
    if num_errors > 0 then
      vim.list_extend(parts, { "%#DiagnosticError#", " 󰅙 ", tostring(num_errors), " " })
    elseif num_warnings > 0 then
      vim.list_extend(parts, { "%#DiagnosticWarn#", "  ", tostring(num_warnings), " " })
    end
  end

  local cs = next_status()
  if cs then
    vim.list_extend(parts, cs)
  end

  table.insert(parts, "%=")
  vim.list_extend(parts, { "%#StatusLine#", "%l:%c", " " })
  local ft = vim.bo.filetype
  if ft and ft ~= "" then
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if clients and #clients > 0 then
      vim.list_extend(parts, { "%#DiagnosticInfo#", "[ ", clients[#clients].name, "] " })
    end
    vim.list_extend(parts, { "%#StatusLine#", ft, " " })
  end
  vim.list_extend(parts, { "%#StatusLine#", "%{&ff}", " " })
  vim.list_extend(parts, { "%#StatusLine#", "%{&fenc}", " " })
  return table.concat(parts, "")
end

function M.git_status()
  return vim.b[0].gitsigns_status_dict
end

function M.file()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.uri_from_bufnr(buf)
  local devicons = require("nvim-web-devicons")
  local icon, name = devicons.get_icon_by_filetype(vim.bo[buf].filetype, { default = true })
  if name then
    return { " ", "%#" .. name .. "#", icon, " %#StatusLine#", M.format_uri(filename) }
  else
    return { " ", icon, " ", M.format_uri(filename) }
  end
end
function M.format_uri(uri)
  if vim.startswith(uri, "jdt://") then
    local jar, pkg, class = uri:match("^jdt://contents/([^/]+)/([^/]+)/(.+)?")
    return string.format("%s::%s (%s)", pkg, class, jar)
  else
    local fname = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":.")
    fname = fname:gsub("src/main/java/", "s/m/j/")
    fname = fname:gsub("src/test/java/", "s/t/j/")
    return fname
  end
end
function M.dap_status()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return ""
  end
  local status = dap.status()
  if status ~= "" then
    return status .. " | "
  end
  return ""
end

function M.tabline()
  local parts = {}
  local devicons = require("nvim-web-devicons")
  for i = 1, vim.fn.tabpagenr("$") do
    local tabpage = vim.fn.gettabinfo(i)[1]
    local winid = tabpage.windows[1]
    if not winid or not vim.api.nvim_win_is_valid(winid) then
      goto continue
    end
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      goto continue
    end
    local bufname = vim.fn.bufname(bufnr)
    local filename = vim.fn.fnamemodify(bufname, ":t")

    local icon, name = devicons.get_icon_by_filetype(vim.bo[bufnr].filetype, { default = true })
    table.insert(parts, "    %#" .. name .. "#")
    table.insert(parts, icon)
    table.insert(parts, " ")
    if i == vim.fn.tabpagenr() then
      table.insert(parts, "%#TabLineSel#")
    else
      table.insert(parts, "%#TabLine#")
    end
    if not filename or filename == "" then
      filename = "[No Name]"
    end
    table.insert(parts, filename)
    ::continue::
  end
  return table.concat(parts, "")
end
return M
