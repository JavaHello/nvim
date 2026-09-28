local sse = require("kide.http.sse")
local max_tokens = 4096 * 2
local code_json = {
  messages = {
    {
      content = "",
      role = "user",
    },
    {
      content = "```python\n",
      prefix = true,
      role = "assistant",
    },
  },
  model = "deepseek-v4-flash",
  thinking = {
    type = "disabled",
  },
  max_tokens = max_tokens,
  stop = "```",
  stream = true,
  temperature = 0.0,
}

local chat_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
  },
  model = "deepseek-v4-flash",
  thinking = {
    type = "disabled",
  },
  frequency_penalty = 0,
  max_tokens = 4096 * 2,
  presence_penalty = 0,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  temperature = 1.3,
  top_p = 1,
  tools = nil,
  tool_choice = "none",
  logprobs = false,
  top_logprobs = nil,
}

local reasoner_json = {
  messages = {},
  model = "deepseek-v4-pro",
  max_tokens = 4096 * 2,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  tools = nil,
  tool_choice = "none",
}

local commit_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
    {
      content = "Hi",
      role = "user",
    },
  },
  model = "deepseek-v4-flash",
  thinking = {
    type = "disabled",
  },
  frequency_penalty = 0,
  max_tokens = 4096 * 2,
  presence_penalty = 0,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  temperature = 1.3,
  top_p = 1,
  tools = nil,
  tool_choice = "none",
  logprobs = false,
  top_logprobs = nil,
}

local translate_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
    {
      content = "Hi",
      role = "user",
    },
  },
  model = "deepseek-v4-flash",
  thinking = {
    type = "disabled",
  },
  frequency_penalty = 0,
  max_tokens = 4096 * 2,
  presence_penalty = 0,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  temperature = 1.3,
  top_p = 1,
  tools = nil,
  tool_choice = "none",
  logprobs = false,
  top_logprobs = nil,
}

---@class gpt.DeepSeekClient : gpt.Client
---@field base_url string
---@field api_key string
---@field type string
---@field payload table
---@field sse http.SseClient?
local DeepSeek = {
  models = {
    "deepseek-v4-flash",
  },
}
DeepSeek.__index = DeepSeek

function DeepSeek.new(type)
  local self = setmetatable({}, DeepSeek)
  self.base_url = "https://api.deepseek.com"
  self.api_key = vim.env["DEEPSEEK_API_KEY"]
  self.type = type or "chat"
  if self.type == "chat" then
    self.payload = chat_json
  elseif self.type == "reasoner" then
    self.payload = reasoner_json
  elseif self.type == "code" then
    self.payload = code_json
  elseif self.type == "commit" then
    self.payload = commit_json
  elseif self.type == "translate" then
    self.payload = translate_json
  end
  return self
end

function DeepSeek.set_model(model)
  DeepSeek._c_model = model
end

function DeepSeek:payload_message(messages)
  local json = vim.deepcopy(self.payload)
  if DeepSeek._c_model then
    json.model = DeepSeek._c_model
  end
  self.model = json.model
  json.messages = messages
  return json
end

function DeepSeek:url()
  if
    self.type == "chat"
    or self.type == "reasoner"
    or self.type == "commit"
    or self.type == "translate"
  then
    return self.base_url .. "/chat/completions"
  elseif self.type == "code" then
    return self.base_url .. "/beta/v1/chat/completions"
  end
end

---@param messages table<gpt.Message>
function DeepSeek:request(messages, callback)
  local payload = self:payload_message(messages)
  local job
  local tmp = ""

  local function callback_data(resp_json)
    -- 401/429/模型名写错等返回的是 {"error": {...}}, 没有 choices.
    -- 只认带 choices 的对象会把这些响应静默吞掉: 不显示内容也不报错,
    -- 所以这里显式提示, 并补 done 结束等待
    if resp_json.error then
      local err = resp_json.error
      local msg = type(err) == "table" and (err.message or vim.inspect(err)) or tostring(err)
      vim.notify("DeepSeek error: " .. msg, vim.log.levels.ERROR, {
        id = "gpt:" .. job,
        title = "DeepSeek",
      })
      callback({ done = true, data = "" })
      return
    end
    for _, message in ipairs(resp_json.choices or {}) do
      callback({
        role = message.delta.role,
        reasoning = message.delta.reasoning_content,
        data = message.delta.content,
        usage = resp_json.usage,
      })
    end
  end

  -- 返回解码后的对象; 流式分片还没拼完整时 json_decode 会失败, 返回 nil 继续累积.
  -- 只接受 table, 免得半截数据里的裸数字/字符串被当成完整响应
  local function decode_complete(text)
    local ok, obj = pcall(vim.fn.json_decode, text)
    if ok and type(obj) == "table" then
      return obj
    end
    return nil
  end
  ---@param event http.SseEvent
  local callback_handle = function(_, event)
    if not event.data then
      -- curl 异常退出(网络中断/HTTP 错误/被 kill)时不会再有 [DONE], 不补 done
      -- 的话调用方的 chatrunning 一直为 true, 下一次 <Enter> 会被当成取消
      if event.exit and event.exit ~= 0 and not event.stopped then
        vim.notify(
          ("请求中断 (curl exit %d)"):format(event.exit),
          vim.log.levels.ERROR,
          { id = "gpt:" .. job, title = "DeepSeek" }
        )
        callback({ done = true, data = "" })
      end
      return
    end
    for _, value in ipairs(event.data) do
      -- 忽略 SSE 换行输出
      if value ~= "" then
        if vim.startswith(value, "data: ") then
          local text = string.sub(value, 7, -1)
          if text == "[DONE]" then
            tmp = ""
            callback({
              data = text,
              done = true,
            })
          else
            tmp = tmp .. text
            local resp_json = decode_complete(tmp)
            if resp_json then
              callback_data(resp_json)
              tmp = ""
            end
          end
        elseif vim.startswith(value, ": keep-alive") then
          -- 这里可能是心跳检测报文, 输出提示
          vim.notify(
            "[SSE] " .. value,
            vim.log.levels.INFO,
            { id = "gpt:" .. job, title = "DeepSeek" }
          )
        else
          tmp = tmp .. value
          local resp_json = decode_complete(tmp)
          if resp_json then
            callback_data(resp_json)
            tmp = ""
          end
        end
      end
    end
  end

  self.sse =
    sse.new(self:url()):POST():auth(self.api_key):body(payload):handle(callback_handle):send()
  job = self.sse.job
end

function DeepSeek:close()
  if self.sse then
    self.sse:stop()
  end
end

return DeepSeek
