local sse = require("kide.http.sse")
local max_tokens = 4096 * 2
local code_json = {
  messages = {
    {
      content = "帮我生成一个快速排序",
      role = "user",
    },
    {
      content = "```python\n",
      prefix = true,
      role = "assistant",
    },
  },
  model = "deepseek-chat",
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
  model = "deepseek-chat",
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
  messages = {
  },
  model = "deepseek-reasoner",
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
  model = "deepseek-chat",
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
  model = "deepseek-chat",
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

function DeepSeek:payload_message(messages)
  local json = vim.deepcopy(self.payload);
  json.messages = messages
  return json
end

function DeepSeek:url()
  if self.type == "chat"
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
  local function callback_data(resp_json)
    for _, message in ipairs(resp_json.choices) do
      callback({
        role = message.delta.role,
        reasoning = message.delta.reasoning_content,
        data = message.delta.content,
        usage = resp_json.usage,
      })
    end
  end
  local job
  local tmp = ""
  ---@param event http.SseEvent
  local callback_handle = function(_, event)
    if not event.data then
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
            local ok, resp_json = pcall(vim.fn.json_decode, text)
            if ok then
              tmp = ""
              callback_data(resp_json)
            else
              tmp = text
            end
          end
        elseif vim.startswith(value, ": keep-alive") then
          -- 这里可能是心跳检测报文, 输出提示
          vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = "DeepSeek" })
        else
          if tmp ~= "" then
            tmp = tmp .. value
            local ok, resp_json = pcall(vim.fn.json_decode, tmp)
            if ok then
              callback_data(resp_json)
            end
          else
            vim.notify("[SSE] parse error: " .. value, vim.log.levels.WARN)
          end
        end
      end
    end
  end

  self.sse = sse.new(self:url())
      :POST()
      :auth(self.api_key)
      :body(payload)
      :handle(callback_handle)
      :send()
  job = self.sse.job
end

function DeepSeek:close()
  if self.sse then
    self.sse:stop()
  end
end

return DeepSeek
