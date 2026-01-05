---@class gpt.Message
---@field role string
---@field content string

---@class gpt.TokenUsage
---@field prompt_cache_hit_tokens number?
---@field prompt_tokens number?
---@field completion_tokens number?
---@field total_tokens number?

---@class gpt.Event
---@field done boolean?
---@field exit number?
---@field data string?
---@field usage gpt.TokenUsage?
---@field reasoning string?

---@class gpt.Client
---@field model string?
---@field models string?
---@field request fun(self: gpt.Client, message: table<gpt.Message>, callback: fun(data: gpt.Event))
---@field close fun(self: gpt.Client)
---@field set_model fun(self: gpt.Client, model: string)

local M = {}
local deepseek = require("kide.gpt.provide.deepseek")
local openrouter = require("kide.gpt.provide.openrouter")
local openai = require("kide.gpt.provide.openai")

local function default_provide()
  local provide = vim.env["NVIM_AI_DEFAULT_PROVIDE"]
  if provide == "openai" then
    return openai
  elseif provide == "deepseek" then
    return deepseek
  elseif provide == "openrouter" then
    return openrouter
  end
end

M.gpt_provide = default_provide() or deepseek
local _list = {
  deepseek = deepseek,
  openrouter = openrouter,
  openai = openai,
}
M.provide_keys = function()
  local keys = {}
  for key, _ in pairs(_list) do
    table.insert(keys, key)
  end
  return keys
end
M.select_provide = function(name)
  M.gpt_provide = _list[name] or deepseek
end

M.models = function()
  return M.gpt_provide.models
end

M.select_model = function(model)
  M.gpt_provide.set_model(model)
end

---@param type string
---@return gpt.Client
function M.new_client(type)
  return M.gpt_provide.new(type)
end

M.GptType = {
  chat = "chat",
  reasoner = "reasoner",
}
return M
