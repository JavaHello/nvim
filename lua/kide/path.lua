local M = {}

function M.shorten(filename, limit)
  filename = filename or ""
  limit = limit or 40

  if filename == "" or vim.fn.strdisplaywidth(filename) <= limit then
    return filename
  end

  local shortened = vim.fn.pathshorten(filename)
  if shortened ~= "" then
    return shortened
  end

  return filename
end

return M
