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
  model = "google/gemini-2.0-flash-001",
  max_tokens = max_tokens,
  stop = "```",
  stream = true,
}

local chat_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
  },
  model = "google/gemini-2.0-flash-001",
  stream = true,
}

local reasoner_json = {
  messages = {
  },
  model = "deepseek/deepseek-r1:free",
  stream = true,
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
  model = "google/gemini-2.0-flash-001",
  stream = true,
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
  model = "google/gemini-2.0-flash-001",
  stream = true,
}

---@class gpt.OpenrouterClient : gpt.Client
---@field base_url string
---@field api_key string
---@field type string
---@field payload table
---@field sse http.SseClient?
local Openrouter = {
  models = {
    "anthropic/claude-sonnet-4.5",
    "anthropic/claude-sonnet-4",
    "anthropic/claude-opus-4.1",
    "anthropic/claude-opus-4",
    "openai/gpt-4o",
    "anthropic/claude-3.7-sonnet",
    "google/gemini-2.0-flash-001",
    "google/gemini-2.5-flash-preview",
    "deepseek/deepseek-chat-v3-0324:free",
    "deepseek/deepseek-chat-v3-0324",
    "qwen/qwen3-235b-a22b",
  }
}
Openrouter.__index = Openrouter

function Openrouter.new(type)
  local self = setmetatable({}, Openrouter)
  self.base_url = "https://openrouter.ai/api/v1"
  self.api_key = vim.env["OPENROUTER_API_KEY"]
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

function Openrouter.set_model(model)
  Openrouter._c_model = model
end

function Openrouter:payload_message(messages)
  self.model = self.payload.model
  local json = vim.deepcopy(self.payload);
  if Openrouter._c_model then
    json.model = Openrouter._c_model
  end
  self.model = json.model
  json.messages = messages
  return json
end

function Openrouter:url()
  if self.type == "chat"
      or self.type == "reasoner"
      or self.type == "commit"
      or self.type == "translate"
  then
    return self.base_url .. "/chat/completions"
  elseif self.type == "code" then
    return self.base_url .. "/chat/completions"
  end
end

---@param messages table<gpt.Message>
function Openrouter:request(messages, callback)
  local payload = self:payload_message(messages)
  local function callback_data(resp_json)
    if resp_json.error then
      vim.notify("Openrouter error: " .. vim.inspect(resp_json), vim.log.levels.ERROR)
      return
    end
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
  local is_json = function(text)
    return (vim.startswith(text, "{") and vim.endswith(text, "}"))
        or (vim.startswith(text, "[") and vim.endswith(text, "]"))
  end
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
            tmp = tmp .. text
            if is_json(tmp) then
              local resp_json = vim.fn.json_decode(tmp)
              callback_data(resp_json)
              tmp = ""
            end
          end
        elseif vim.startswith(value, ": keep-alive") then
          -- 这里可能是心跳检测报文, 输出提示
          vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = "Openrouter" })
        elseif vim.startswith(value, ": OPENROUTER PROCESSING") then
          -- ignore
          -- vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = "Openrouter" })
        else
          tmp = tmp .. value
          if is_json(tmp) then
            local resp_json = vim.fn.json_decode(tmp)
            callback_data(resp_json)
            tmp = ""
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

function Openrouter:close()
  if self.sse then
    self.sse:stop()
  end
end

return Openrouter
