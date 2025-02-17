local M = {}

M.config = {
  API_URL = vim.env["DEEPSEEK_API_ENDPOINT"],
  API_KEY = vim.env["DEEPSEEK_API_KEY"],
}

local function token()
  return "Bearer " .. M.config.API_KEY
end

local function callback_data(job, resp_json, callback)
  for _, message in ipairs(resp_json.choices) do
    callback({
      role = message.delta.role,
      reasoning = message.delta.reasoning_content,
      data = message.delta.content,
      job = job,
      usage = resp_json.usage,
    })
  end
end

---@param cmd string[]
---@param callback fun(opt)
local function handle_sse_events(cmd, callback, opts)
  local title = opts.title or "Gpt"
  local sid = require("kide").timer_stl_status("")
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
          elseif vim.startswith(value, ": keep-alive") then
            -- 这里可能是心跳检测报文, 输出提示
            vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = title })
          else
            if tmp ~= "" then
              tmp = tmp .. value
              local ok, resp_json = pcall(vim.fn.json_decode, tmp)
              if ok then
                callback_data(job, resp_json, callback)
              end
            else
              vim.notify("[SSE] parse error: " .. value, vim.log.levels.WARN)
            end
          end
        end
      end
    end,
    on_stderr = function(_, _, _) end,
    on_exit = function(_, code, _)
      require("kide").clean_stl_status(sid, code)
      callback({
        data = nil,
        done = true,
        job = job,
      })
    end,
  })
  return job
end

---@param json table
---@param callback function
---@param opts? table
---@return integer
function M.request(json, callback, opts)
  local body = vim.fn.json_encode(json)
  opts = opts or {}
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
    opts.url or M.config.API_URL,
  }
  return handle_sse_events(cmd, callback, opts)
end

return M
