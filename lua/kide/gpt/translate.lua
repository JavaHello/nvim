local M = {}

local request_json = {
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
  max_tokens = 256,
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

---@param request kai.tools.TranslateRequest
local function trans_system_prompt(request)
  local from = request.from
  if request.from == "auto" then
    return "你会得到一个需要你检测语言的文本， 将他翻译为" .. request.to .. "。"
  end
  return "你会得到一个" .. from .. "文本， 将他翻译为" .. request.to .. "。"
end

---@param request kai.tools.TranslateRequest
---@param callback fun(data: string)
function M.translate(request, callback)
  local json = request_json
  json.messages[1].content = trans_system_prompt(request)
  json.messages[2].content = request.text
  local text_len = request.text:len()
  if text_len > 256 then
    json.max_tokens = 512
  elseif text_len > 512 then
    json.max_tokens = 1024
  elseif text_len > 1024 then
    json.max_tokens = 2048
  elseif text_len > 2048 then
    json.max_tokens = 4096
  end
  require("kide.gpt.sse").request(json, callback)
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
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].number = false -- 不显示行号

  local closed = false
  vim.keymap.set("n", "q", function()
    closed = true
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })

  local curlines = 0
  local callback = function(opt)
    local data = opt.data
    local done = opt.done
    if closed then
      vim.fn.jobstop(opt.job)
      return
    end
    if done then
      vim.bo[buf].readonly = true
      vim.bo[buf].modifiable = false
      return
    end
    -- 判断是否换行符
    if data:match("\n") then
      curlines = 0
    else
      curlines = curlines + vim.fn.strdisplaywidth(data)
    end

    -- 自动调整窗口宽度
    -- 出现在中文翻译为英文时, 英文长度会超过中文
    if curlines > width and curlines < max_width then
      width = curlines
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_width(win, width)
      end
    end

    if vim.api.nvim_buf_is_valid(buf) then
      if data:match("\n") then
        local ln = vim.split(data, "\n")
        vim.api.nvim_put(ln, "c", true, true)
      else
        vim.api.nvim_put({ data }, "c", true, true)
      end
    end
  end
  M.translate(request, callback)
end

return M
