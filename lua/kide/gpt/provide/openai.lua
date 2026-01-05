local sse = require("kide.http.sse")
local max_output_tokens = 4096 * 2
local code_json = {
  input = {},
  model = "gpt-4o",
  max_output_tokens = max_output_tokens,
  stop = "```",
  stream = true,
  temperature = 0.0,
}

local chat_json = {
  input = {},
  model = "gpt-4o",
  max_output_tokens = max_output_tokens,
  text = {
    format = {
      type = "text",
    },
  },
  stream = true,
  temperature = 1.3,
  top_p = 1,
}

local reasoner_json = {
  input = {},
  model = "gpt-4o",
  max_output_tokens = max_output_tokens,
  stream = true,
}

local commit_json = {
  input = {},
  model = "gpt-4o",
  max_output_tokens = max_output_tokens,
  text = {
    format = {
      type = "text",
    },
  },
  stream = true,
  temperature = 1.0,
  top_p = 1,
}

local translate_json = {
  input = {},
  model = "gpt-4o",
  max_output_tokens = max_output_tokens,
  text = {
    format = {
      type = "text",
    },
  },
  stream = true,
  temperature = 1.3,
  top_p = 1,
}

---@class gpt.OpenAIClient : gpt.Client
---@field base_url string
---@field api_key string
---@field type string
---@field payload table
---@field sse http.SseClient?
local OpenAI = {
  models = {
    "gpt-4o",
    "gpt-4o-mini",
  },
}
OpenAI.__index = OpenAI

function OpenAI.new(type)
  local self = setmetatable({}, OpenAI)
  self.base_url = "https://api.openai.com/v1"
  self.api_key = vim.env["OPENAI_API_KEY"]
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

function OpenAI.set_model(model)
  OpenAI._c_model = model
end

function OpenAI:payload_message(messages)
  local json = vim.deepcopy(self.payload)
  if OpenAI._c_model then
    json.model = OpenAI._c_model
  end
  self.model = json.model
  local input = {}
  for _, message in ipairs(messages) do
    if type(message.content) == "table" then
      input[#input + 1] = {
        role = message.role,
        content = message.content,
      }
    else
      input[#input + 1] = {
        role = message.role,
        content = {
          {
            type = "input_text",
            text = message.content or "",
          },
        },
      }
    end
  end
  json.input = input
  return json
end

function OpenAI:url()
  return self.base_url .. "/responses"
end

---@param messages table<gpt.Message>
function OpenAI:request(messages, callback)
  local payload = self:payload_message(messages)
  local function normalize_usage(usage)
    if not usage then
      return nil
    end
    local cached_tokens = nil
    if usage.input_tokens_details and usage.input_tokens_details.cached_tokens then
      cached_tokens = usage.input_tokens_details.cached_tokens
    end
    return {
      prompt_cache_hit_tokens = cached_tokens,
      prompt_tokens = usage.input_tokens,
      completion_tokens = usage.output_tokens,
      total_tokens = usage.total_tokens,
    }
  end
  local function callback_data(resp_json, event_type)
    if resp_json.error then
      vim.notify("OpenAI error: " .. vim.inspect(resp_json), vim.log.levels.ERROR)
      return
    end
    local etype = resp_json.type or event_type
    if etype == "response.output_text.delta" then
      local text = resp_json.delta or resp_json.text or resp_json.content or ""
      if text ~= "" then
        callback({
          data = text,
        })
      end
    elseif etype == "response.reasoning.delta" then
      local text = resp_json.delta or resp_json.text or resp_json.content or ""
      if text ~= "" then
        callback({
          reasoning = text,
        })
      end
    elseif etype == "response.completed" then
      local usage = nil
      if resp_json.response and resp_json.response.usage then
        usage = normalize_usage(resp_json.response.usage)
      end
      callback({
        usage = usage,
        done = true,
        data = "",
      })
    elseif etype == "response.failed" or etype == "response.cancelled" then
      callback({
        done = true,
        data = "",
      })
    end
  end
  local job
  local tmp = ""
  local current_event = nil
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
        if vim.startswith(value, "event: ") then
          current_event = string.sub(value, 8, -1)
        elseif vim.startswith(value, "data: ") then
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
              callback_data(resp_json, current_event)
              current_event = nil
              tmp = ""
            end
          end
        elseif vim.startswith(value, ": keep-alive") then
          -- 这里可能是心跳检测报文, 输出提示
          vim.notify("[SSE] " .. value, vim.log.levels.INFO, { id = "gpt:" .. job, title = "OpenAI" })
        else
          tmp = tmp .. value
          if is_json(tmp) then
            local resp_json = vim.fn.json_decode(tmp)
            callback_data(resp_json, current_event)
            current_event = nil
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

function OpenAI:close()
  if self.sse then
    self.sse:stop()
  end
end

return OpenAI
