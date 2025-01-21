local M = {}
function M.usage_str(usage)
  local data = "[token usage: "
    .. vim.inspect(usage.prompt_cache_hit_tokens)
    .. "  "
    .. vim.inspect(usage.prompt_tokens)
    .. " + "
    .. vim.inspect(usage.completion_tokens)
    .. " = "
    .. vim.inspect(usage.total_tokens)
    .. " ]"
  return data
end
return M
