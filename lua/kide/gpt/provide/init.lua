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

---@class gpt.Client
---@field request fun(self: gpt.Client, message: table<gpt.Message>, callback: fun(data: gpt.Event))
---@field close fun(self: gpt.Client)

local M = {}
local deepseek = require("kide.gpt.provide.deepseek")

M.gpt_provide = deepseek

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
