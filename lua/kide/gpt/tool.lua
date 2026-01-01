local M = {}
---@param usage gpt.TokenUsage
---@return string
function M.usage_str(title, usage)
  local data = "[token usage: "
    .. vim.inspect(usage.prompt_cache_hit_tokens or 0)
    .. "  "
    .. vim.inspect(usage.prompt_tokens)
    .. " + "
    .. vim.inspect(usage.completion_tokens)
    .. " = "
    .. vim.inspect(usage.total_tokens)
    .. " ] " .. title
  return data
end
return M
