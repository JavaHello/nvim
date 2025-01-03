local M = {}

M.config = {
  API_URL = vim.env["DEEPSEEK_API_ENDPOINT"],
  API_KEY = vim.env["DEEPSEEK_API_KEY"],
  show_usage = false,
}

local function token()
  return "Bearer " .. M.config.API_KEY
end

local function callback_data(job, resp_json, callback)
  callback({
    data = resp_json.choices[1].delta.content,
    job = job,
  })
  if resp_json.usage ~= nil and M.config.show_usage then
    callback({
      data = "\n",
      job = job,
    })
    callback({
      data = "API[token usage]: " .. vim.inspect(resp_json.usage.prompt_cache_hit_tokens) .. "  " .. vim.inspect(
        resp_json.usage.prompt_tokens
      ) .. " + " .. vim.inspect(resp_json.usage.completion_tokens) .. " = " .. vim.inspect(
        resp_json.usage.total_tokens
      ),
      job = job,
    })
  end
end

---@param cmd string[]
---@param callback fun(opt)
local function handle_sse_events(cmd, callback)
  local job
  local tmp = ""
  job = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, value in ipairs(data) do
        -- 忽略 SSE 换行输出
        if value ~= "" then
          if vim.startswith(value, "data: ") then
            local text = string.sub(value, 7, -1)
            if text == "[DONE]" then
              tmp = ""
              callback({
                data = text,
                done = true,
                job = job,
              })
            else
              local ok, resp_json = pcall(vim.fn.json_decode, text)
              if ok then
                tmp = ""
                callback_data(job, resp_json, callback)
              else
                tmp = text
              end
            end
          else
            if tmp ~= "" then
              tmp = tmp .. value
              local ok, resp_json = pcall(vim.fn.json_decode, tmp)
              if ok then
                callback_data(job, resp_json, callback)
              end
            else
              vim.notify("SSE parse error: " .. value, vim.log.levels.WARN)
            end
          end
        end
      end
    end,
    on_stderr = function(_, _, _) end,
    on_exit = function(_, _, _) end,
  })
end

function M.request(json, callback)
  local body = vim.fn.json_encode(json)
  local cmd = {
    "curl",
    "--no-buffer",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization:" .. token(),
    "-d",
    body,
    M.config.API_URL,
  }
  handle_sse_events(cmd, callback)
end

return M
