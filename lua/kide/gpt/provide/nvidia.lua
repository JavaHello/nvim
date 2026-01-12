local sse = require("kide.http.sse")
local max_tokens = 2048
local model = "minimaxai/minimax-m2"

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
  model = model,
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
  model = model,
  max_tokens = max_tokens,
  temperature = 0.15,
  top_p = 1.0,
  frequency_penalty = 0.0,
  presence_penalty = 0.0,
  stream = true,
}

local reasoner_json = {
  messages = {},
  model = model,
  max_tokens = max_tokens,
  temperature = 0.15,
  top_p = 1.0,
  frequency_penalty = 0.0,
  presence_penalty = 0.0,
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
  model = model,
  max_tokens = max_tokens,
  temperature = 0.15,
  top_p = 1.0,
  frequency_penalty = 0.0,
  presence_penalty = 0.0,
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
  model = model,
  max_tokens = max_tokens,
  temperature = 0.15,
  top_p = 1.0,
  frequency_penalty = 0.0,
  presence_penalty = 0.0,
  stream = true,
}

---@class gpt.NvidiaClient : gpt.Client
---@field base_url string
---@field api_key string
---@field type string
---@field payload table
---@field sse http.SseClient?
local Nvidia = {
  models = {
    "minimaxai/minimax-m2",
    "deepseek-ai/deepseek-v3.2",
    "qwen/qwen3-next-80b-a3b-instruct",
    "mistralai/ministral-14b-instruct-2512",
  },
}
Nvidia.__index = Nvidia

function Nvidia.new(type)
  local self = setmetatable({}, Nvidia)
  self.base_url = "https://integrate.api.nvidia.com/v1"
  self.api_key = vim.env["NVIDIA_API_KEY"]
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

function Nvidia.set_model(model)
  Nvidia._c_model = model
end

function Nvidia:payload_message(messages)
  local json = vim.deepcopy(self.payload)
  if Nvidia._c_model then
    json.model = Nvidia._c_model
  end
  self.model = json.model
  json.messages = messages
  return json
end

function Nvidia:url()
  return self.base_url .. "/chat/completions"
end

---@param messages table<gpt.Message>
function Nvidia:request(messages, callback)
  local payload = self:payload_message(messages)
  local function callback_data(resp_json)
    if resp_json.error then
      vim.notify("NVIDIA error: " .. vim.inspect(resp_json), vim.log.levels.ERROR)
      return
    end
    for _, message in ipairs(resp_json.choices) do
      if message.finish_reason == vim.NIL then
        callback({
          role = message.delta.role,
          data = message.delta.content,
          usage = nil,
        })
      end
    end
  end
  local job
  local tmp = ""
  local is_json = function(text)
    local ok, _ = pcall(vim.fn.json_decode, text)
    return ok
  end
  ---@param event http.SseEvent
  local callback_handle = function(_, event)
    if not event.data then
      return
    end
    for _, value in ipairs(event.data) do
      if value ~= "" then
        if vim.startswith(value, "data: ") then
          local text = string.sub(value, 7, -1)
          if text == "[DONE]" then
            tmp = ""
            callback({
              data = text,
              done = true,
              usage = {},
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
          vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = "NVIDIA" })
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

  self.sse = sse.new(self:url()):POST():auth(self.api_key):body(payload):handle(callback_handle):send()
  job = self.sse.job
end

function Nvidia:close()
  if self.sse then
    self.sse:stop()
  end
end

return Nvidia
