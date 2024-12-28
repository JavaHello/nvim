local M = {}
-- 参考 https://github.com/mfussenegger/dotfiles
function M.statusline()
  local counts = vim.diagnostic.count(0, { severity = { min = vim.diagnostic.severity.WARN } })
  local fstatus = M.file_or_lsp_status()
  local parts = {
    "%< ",
    fstatus,
  }
  local num_errors = counts[vim.diagnostic.severity.ERROR] or 0
  local num_warnings = counts[vim.diagnostic.severity.WARN] or 0
  table.insert(parts, "%#DiagnosticWarn#%r%m")
  if num_errors > 0 then
    vim.list_extend(parts, { "%#DiagnosticError#", " 󰅙 ", tostring(num_errors), " " })
  elseif num_warnings > 0 then
    vim.list_extend(parts, { "%#DiagnosticWarn#", "  ", tostring(num_warnings), " " })
  end
  table.insert(parts, "%=")
  vim.list_extend(parts, { "%#StatusLine#", "%l:%c", " " })
  vim.list_extend(parts, { "%#StatusLine#", "%y", " " })
  vim.list_extend(parts, { "%#StatusLine#", "%{&ff}", " " })
  vim.list_extend(parts, { "%#StatusLine#", "%{&fenc}", " " })
  return table.concat(parts, "")
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
      return string.format("%%#%s#%s %%#StatusLine#%s", name, icon, M.format_uri(filename))
    else
      return string.format("%s %s", icon, M.format_uri(filename))
    end
  end
  return lsp_status
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

return M
