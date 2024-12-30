local M = {}

---@class kai.tools.TranslateRequest
---@field text string
---@field from string
---@field to string

M.config = {
  API_URL = vim.env["DEEPSEEK_API_ENDPOINT"],
  API_KEY = vim.env["DEEPSEEK_API_KEY"],
  show_usage = false,
}

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

local function token()
  return "Bearer " .. M.config.API_KEY
end

---@param cmd string[]
---@param callback fun(data: string, done: boolean)
local function handle_sse_events(cmd, callback)
  local _ = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, value in ipairs(data) do
        if vim.startswith(value, "data:") then
          local _, _, text = string.find(value, "data: (.+)")
          if text == "[DONE]" then
            callback(text, true)
          else
            local ok, resp_json = pcall(vim.fn.json_decode, text)
            if ok then
              if resp_json.usage ~= nil and M.config.show_usage then
                callback("\n", false)
                callback(
                  "API[token usage]: "
                    .. vim.inspect(resp_json.usage.prompt_cache_hit_tokens)
                    .. "  "
                    .. vim.inspect(resp_json.usage.prompt_tokens)
                    .. " + "
                    .. vim.inspect(resp_json.usage.completion_tokens)
                    .. " = "
                    .. vim.inspect(resp_json.usage.total_tokens),
                  false
                )
              else
                callback(resp_json.choices[1].delta.content, false)
              end
            else
              callback("Error: " .. text, false)
            end
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
  M.request(json, callback)
end

function M.request(json, callback)
  local body = vim.fn.json_encode(json)
  local cmd = {
    "curl",
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
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].number = false -- 不显示行号

  local closed = false
  vim.keymap.set("n", "q", function()
    closed = true
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })

  local curlines = 0
  local callback = function(data, done)
    if closed then
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

------------------ chat ------------------
local charwin = nil
local charbuf = nil
local chatclosed = false
local chatruning = false
local chat_request_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
  },
  model = "deepseek-chat",
  frequency_penalty = 0,
  max_tokens = 4096,
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

M.chat_config = {
  user_title = " :",
  system_title = " :",
  system_prompt = "You are a general AI assistant.\n\n"
    .. "The user provided the additional info about how they would like you to respond:\n\n"
    .. "- If you're unsure don't guess and say you don't know instead.\n"
    .. "- Ask question if you need clarification to provide better answer.\n"
    .. "- Think deeply and carefully from first principles step by step.\n"
    .. "- Zoom out first to see the big picture and then zoom in to details.\n"
    .. "- Use Socratic method to improve your thinking and coding skills.\n"
    .. "- Don't elide any code from your output if the answer requires coding.\n"
    .. "- Take a deep breath; You've got this!\n",
}
local close_gpt_win = function()
  chatruning = false
  if charwin then
    pcall(vim.api.nvim_win_close, charwin, true)
    charwin = nil
    charbuf = nil
    chat_request_json.messages = {
      {
        content = "",
        role = "system",
      },
    }
  end
end

local function create_gpt_win()
  vim.cmd("belowright new")
  charwin = vim.api.nvim_get_current_win()
  charbuf = vim.api.nvim_get_current_buf()
  vim.bo[charbuf].buftype = "nofile"
  vim.bo[charbuf].bufhidden = "wipe"
  vim.bo[charbuf].buflisted = false
  vim.bo[charbuf].swapfile = false
  vim.bo[charbuf].filetype = "markdown"
  vim.api.nvim_put({ M.chat_config.user_title, "" }, "c", true, true)
  chatclosed = false

  vim.keymap.set("n", "q", function()
    chatclosed = true
    close_gpt_win()
  end, { noremap = true, silent = true, buffer = charbuf })
  vim.keymap.set("n", "<A-k>", function()
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = charbuf })
  vim.keymap.set("i", "<A-k>", function()
    vim.cmd("stopinsert")
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = charbuf })

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = charbuf,
    callback = close_gpt_win,
  })
end

M.toggle_gpt = function()
  if charwin then
    close_gpt_win()
  else
    create_gpt_win()
  end
end

M.gpt_chat = function()
  if charwin == nil then
    create_gpt_win()
  end
  if chatruning then
    return
  end
  chatruning = true
  local list = vim.api.nvim_buf_get_lines(charbuf, 0, -1, false)
  local json = chat_request_json
  json.messages[1].content = M.chat_config.system_prompt
  -- 1 user, 2 assistant
  local flag = 0
  local chat_msg = ""
  local chat_count = 1
  for _, v in ipairs(list) do
    if vim.startswith(v, M.chat_config.system_title) then
      flag = 2
      chat_msg = ""
      chat_count = chat_count + 1
    elseif vim.startswith(v, M.chat_config.user_title) then
      chat_msg = ""
      flag = 1
      chat_count = chat_count + 1
    else
      chat_msg = chat_msg .. "\n" .. v
      json.messages[chat_count] = {
        content = chat_msg,
        role = flag == 1 and "user" or "assistant",
      }
    end
  end
  -- 跳转到最后一行
  vim.cmd("normal! G")
  vim.api.nvim_put({ "", M.chat_config.system_title, "" }, "l", true, true)

  local callback = function(data, done)
    if chatclosed then
      return
    end
    if done then
      vim.api.nvim_put({ "", "", M.chat_config.user_title, "" }, "c", true, true)
      chatruning = false
      return
    end
    if charbuf and vim.api.nvim_buf_is_valid(charbuf) then
      if data:match("\n") then
        local ln = vim.split(data, "\n")
        vim.api.nvim_put(ln, "c", true, true)
      else
        vim.api.nvim_put({ data }, "c", true, true)
      end
    end
  end

  M.request(json, callback)
end

return M
