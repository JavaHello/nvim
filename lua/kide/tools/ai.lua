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

local function callback_data(job, resp_json, callback)
  callback({
    data = resp_json.choices[1].delta.content,
    job = job,
  })
  if resp_json.usage ~= nil and M.config.show_usage then
    callback({
      data = "\n",
      job = job,
    })
    callback({
      data = "API[token usage]: " .. vim.inspect(resp_json.usage.prompt_cache_hit_tokens) .. "  " .. vim.inspect(
        resp_json.usage.prompt_tokens
      ) .. " + " .. vim.inspect(resp_json.usage.completion_tokens) .. " = " .. vim.inspect(
        resp_json.usage.total_tokens
      ),
      job = job,
    })
  end
end

---@param cmd string[]
---@param callback fun(opt)
local function handle_sse_events(cmd, callback)
  local job
  local tmp = ""
  job = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, value in ipairs(data) do
        -- 忽略 SSE 换行输出
        if value ~= "" then
          if vim.startswith(value, "data: ") then
            local text = string.sub(value, 7, -1)
            if text == "[DONE]" then
              tmp = ""
              callback({
                data = text,
                done = true,
                job = job,
              })
            else
              local ok, resp_json = pcall(vim.fn.json_decode, text)
              if ok then
                tmp = ""
                callback_data(job, resp_json, callback)
              else
                tmp = text
              end
            end
          else
            if tmp ~= "" then
              tmp = tmp .. value
              local ok, resp_json = pcall(vim.fn.json_decode, tmp)
              if ok then
                callback_data(job, resp_json, callback)
              end
            else
              vim.notify("SSE parse error: " .. value, vim.log.levels.WARN)
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

------------------ chat ------------------
local chatwin = nil
local chatbuf = nil
local codebuf = nil
local chatclosed = false
local cursormoved = false
local chatruning = false
local winleave = false
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
  if chatwin then
    pcall(vim.api.nvim_win_close, chatwin, true)
    chatwin = nil
    chatbuf = nil
    codebuf = nil
    chat_request_json.messages = {
      {
        content = "",
        role = "system",
      },
    }
  end
end

local function create_gpt_win()
  codebuf = vim.api.nvim_get_current_buf()
  vim.cmd("belowright new")
  chatwin = vim.api.nvim_get_current_win()
  chatbuf = vim.api.nvim_get_current_buf()
  vim.bo[chatbuf].buftype = "nofile"
  vim.bo[chatbuf].bufhidden = "wipe"
  vim.bo[chatbuf].buflisted = false
  vim.bo[chatbuf].swapfile = false
  vim.bo[chatbuf].filetype = "markdown"
  vim.api.nvim_put({ M.chat_config.user_title, "" }, "c", true, true)
  chatclosed = false

  vim.keymap.set("n", "q", function()
    chatclosed = true
    close_gpt_win()
  end, { noremap = true, silent = true, buffer = chatbuf })
  vim.keymap.set("n", "<A-k>", function()
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = chatbuf })
  vim.keymap.set("i", "<A-k>", function()
    vim.cmd("stopinsert")
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = chatbuf })

  vim.api.nvim_buf_create_user_command(chatbuf, "GptSend", function()
    M.gpt_chat()
  end, { desc = "Gpt Send" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = chatbuf,
    callback = close_gpt_win,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = chatbuf,
    callback = close_gpt_win,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = chatbuf,
    callback = function()
      winleave = true
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = chatbuf,
    callback = function()
      cursormoved = true
    end,
  })
end

local function code_question(selection)
  if not selection then
    return
  end
  local qs
  ---@diagnostic disable-next-line: param-type-mismatch
  if vim.api.nvim_buf_is_valid(codebuf) then
    local filetype = vim.bo[codebuf].filetype or "text"
    local filename = vim.fn.fnamemodify(vim.fn.bufname(codebuf), ":.")
    qs = {
      "请解释`" .. filename .. "`文件中的这段代码",
      "```" .. filetype,
    }
  else
    qs = {
      "请解释这段代码",
      "```",
    }
  end
  vim.list_extend(qs, selection)
  table.insert(qs, "```")
  vim.api.nvim_put(qs, "c", true, true)
end

M.toggle_gpt = function(selection)
  if chatwin then
    close_gpt_win()
  else
    create_gpt_win()
    code_question(selection)
  end
end

M.gpt_chat = function()
  if chatwin == nil then
    create_gpt_win()
  end
  if chatruning then
    vim.api.nvim_put({ "", "", M.chat_config.user_title, "" }, "c", true, true)
    chatruning = false
    return
  end
  chatruning = true
  ---@diagnostic disable-next-line: param-type-mismatch
  local list = vim.api.nvim_buf_get_lines(chatbuf, 0, -1, false)
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
  vim.cmd("normal! G$")
  vim.api.nvim_put({ "", M.chat_config.system_title, "" }, "l", true, true)

  local callback = function(opt)
    local data = opt.data
    local done = opt.done
    if chatclosed or chatruning == false then
      vim.fn.jobstop(opt.job)
      return
    end
    if opt.err == 1 then
      vim.notify("AI respond Error: " .. opt.data, vim.log.levels.WARN)
      return
    end
    if winleave then
      -- 防止回答问题时光标已经移动走了
      vim.api.nvim_set_current_win(chatwin)
      winleave = false
    end
    if cursormoved then
      -- 防止光标移动打乱回答顺序, 总是移动到最后一行
      vim.cmd("normal! G$")
      cursormoved = false
    end
    if done then
      vim.api.nvim_put({ "", "", M.chat_config.user_title, "" }, "c", true, true)
      chatruning = false
      return
    end
    if chatbuf and vim.api.nvim_buf_is_valid(chatbuf) then
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
