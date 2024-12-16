local M = {}

---@class kai.tools.TranslateRequest
---@field text string
---@field from string
---@field to string

M.config = {
  API_URL = vim.env["DEEPSEEK_API_ENDPOINT"],
  API_KEY = vim.env["DEEPSEEK_API_KEY"],
}

local request_json = {
  messages = {
    {
      content = "You will be provided with a sentence in {{from}}, and your task is to translate it into {{to}}.",
      role = "system",
    },
    {
      content = "Hi",
      role = "user",
    },
  },
  model = "deepseek-chat",
  frequency_penalty = 0,
  max_tokens = 256,
  presence_penalty = 0,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  temperature = 1,
  top_p = 1,
  tools = nil,
  tool_choice = "none",
  logprobs = false,
  top_logprobs = nil,
}

---@param request kai.tools.TranslateRequest
local function system_prompt(request)
  local from = request.from
  if request.from == "auto" then
    from = "(detect language)"
  end
  return "You will be provided with a sentence in "
    .. from
    .. ", and your task is to translate it into "
    .. request.to
    .. "."
end

local function token()
  return "Bearer " .. M.config.API_KEY
end

---@param cmd string[]
---@param callback fun(data: string)
local function handle_sse_events(cmd, callback)
  local _ = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, value in ipairs(data) do
        if vim.startswith(value, "data:") then
          local _, _, text = string.find(value, "data: (.+)")
          if text ~= "[DONE]" then
            local resp_json = vim.fn.json_decode(text)
            callback(resp_json.choices[1].delta.content)
          end
        end
      end
    end,
    on_stderr = function(_, _, _) end,
    on_exit = function(_, _, _) end,
  })
end

---@param request kai.tools.TranslateRequest
---@param callback fun(data: string)
function M.translate(request, callback)
  local json = request_json
  json.messages[1].content = system_prompt(request)
  json.messages[2].content = request.text
  local body = vim.fn.json_encode(json)
  local cmd = {
    "curl",
    "-N",
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

local max_width = 120
local max_height = 40

M.translate_float = function(request)
  local ctext = vim.fn.split(request.text, "\n")
  local width = math.min(max_width, vim.fn.strdisplaywidth(ctext[1]))
  for _, line in ipairs(ctext) do
    local l = vim.fn.strdisplaywidth(line)
    if l > width and l < max_width then
      width = l
    end
  end
  local height = math.min(max_height, #ctext)

  local opts = {
    relative = "cursor",
    row = 1, -- 相对于光标位置的行偏移
    col = 0, -- 相对于光标位置的列偏移
    width = width, -- 窗口的宽度
    height = height, -- 窗口的高度
    style = "minimal", -- 最小化样式
    border = "rounded", -- 窗口边框样式
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>q<CR>", { noremap = true, silent = true })
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].number = false -- 不显示行号

  local curlines = { "" }
  local callback = function(data)
    -- 判断是否换行符
    if data == "\n" then
      curlines[#curlines + 1] = ""
    else
      curlines[#curlines] = curlines[#curlines] .. data
    end

    -- 自动调整窗口宽度. 出现在中文翻译为英文时, 英文长度会超过中文
    local l = vim.fn.strdisplaywidth(curlines[#curlines])
    if l > width and l < max_width then
      width = l
      vim.api.nvim_win_set_width(win, width)
    end

    -- 判断 buffer 是否可用
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, curlines)
    end
  end
  M.translate(request, callback)
end

return M
