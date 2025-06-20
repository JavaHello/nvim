---@class http.SseEvent
---@field data table<string>?
---@field exit number?

---@class http.SseClient
---@field url string
---@field method string?
---@field token string?
---@field payload string?
---@field callback fun(error, event: http.SseEvent)?
---@field job number?
local SseClient = {}
SseClient.__index = SseClient

---@return http.SseClient
function SseClient.new(url)
  local self = setmetatable({}, SseClient)
  self.url = url
  return self
end

---@return http.SseClient
function SseClient:POST()
  self.method = "POST"
  return self
end

---@return http.SseClient
function SseClient:body(body)
  self.payload = body
  return self
end

---@return http.SseClient
function SseClient:handle(handle)
  self.callback = handle
  return self
end

---@return http.SseClient
function SseClient:auth(token)
  self.token = token
  return self
end

---@param client http.SseClient
---@return table
local function _cmd(client)
  local body = vim.fn.json_encode(client.payload)
  local cmd = {
    "curl",
    "--no-buffer",
    "-s",
    "-X",
    client.method,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. client.token,
    "-d",
    body,
    client.url,
  }
  return cmd
end

---@param client http.SseClient
local function handle_sse_events(client)
  local sid = require("kide").timer_stl_status("")
  client.job = vim.fn.jobstart(_cmd(client), {
    on_stdout = function(_, data, _)
      client.callback(nil, {
        data = data,
      })
    end,
    on_stderr = function(_, _, _)
    end,
    on_exit = function(_, code, _)
      require("kide").clean_stl_status(sid, code)
      client.callback(nil, {
        data = nil,
        exit = code,
      })
    end,
  })
end

---@return http.SseClient
function SseClient:send()
  handle_sse_events(self)
  return self
end

function SseClient:stop()
  if self.job then
    pcall(vim.fn.jobstop, self.job)
  end
end

return SseClient
