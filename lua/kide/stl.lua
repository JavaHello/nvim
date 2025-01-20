local M = {}
M.current_status = {
  index = 0,
  code = nil,
  code_msg = nil,
  progress = { "   ", "  ", " ", "" },
  title = nil,
}
local function next_status()
  if M.current_status.title then
    if M.current_status.index >= #M.current_status.progress then
      M.current_status.index = 0
    end
    M.current_status.index = M.current_status.index + 1
    return {
      title = M.current_status.title,
      progress = M.current_status.progress[M.current_status.index],
    }
  end
end

function M.exit_status(code)
  if code then
    M.current_status.code_buf = vim.api.nvim_get_current_buf()
    M.current_status.code = code
    if code == 0 then
      M.current_status.code_msg = (M.current_status.title or "") .. " SUCCESS"
    else
      M.current_status.code_msg = (M.current_status.title or "") .. " FAILED"
    end
    vim.defer_fn(function()
      M.current_status.code = nil
      M.current_status.code_buf = nil
      M.current_status.code_msg = nil
    end, 2000)
  end
  M.current_status.title = nil
  M.current_status.index = 0
  vim.cmd.redrawstatus()
end
---@param title string
function M.update_status(title)
  M.current_status.title = title
end

-- 参考 https://github.com/mfussenegger/dotfiles
function M.statusline()
  local parts = {
    "%<",
  }
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
  local fstatus = M.file_or_lsp_status()
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

  local cs = next_status()
  if cs then
    table.insert(parts, " %#DiagnosticWarn#" .. cs.title .. " " .. cs.progress)
  end
  if M.current_status.code and M.current_status.code_buf == vim.api.nvim_get_current_buf() then
    if M.current_status.code == 0 then
      table.insert(parts, " %#DiagnosticInfo#" .. M.current_status.code_msg)
    else
      table.insert(parts, " %#DiagnosticError#" .. M.current_status.code_msg)
    end
  end

  table.insert(parts, "%=")
  vim.list_extend(parts, { "%#StatusLine#", "%l:%c", " " })
  local ft = vim.bo.filetype
  if ft and ft ~= "" then
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if clients and #clients > 0 then
      vim.list_extend(parts, { "%#DiagnosticInfo#", "[ ", clients[1].name, "] " })
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

function M.file_or_lsp_status()
  local mode = vim.api.nvim_get_mode().mode
  local lsp_status = vim.lsp.status()
  if mode ~= "n" or lsp_status == "" then
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
  return { " ", "%#StatusLine#", lsp_status }
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
    local winnr = tabpage.windows[1]
    local bufnr = vim.fn.winbufnr(winnr)
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
  end
  return table.concat(parts, "")
end
return M
