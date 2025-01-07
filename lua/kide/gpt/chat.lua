local M = {}
local state = {
  chatwin = nil,
  chatbuf = nil,
  codebuf = nil,
  chatclosed = true,
  cursormoved = false,
  chatruning = false,
  winleave = false,
}

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
  if state.chatwin then
    pcall(vim.api.nvim_win_close, state.chatwin, true)
    chat_request_json.messages = {
      {
        content = "",
        role = "system",
      },
    }
    state.chatwin = nil
    state.chatbuf = nil
    state.codebuf = nil
    state.chatclosed = true
    state.cursormoved = false
    state.chatruning = false
    state.winleave = false
  end
end

local function create_gpt_win()
  state.codebuf = vim.api.nvim_get_current_buf()
  vim.cmd("belowright new")
  state.chatwin = vim.api.nvim_get_current_win()
  state.chatbuf = vim.api.nvim_get_current_buf()
  vim.bo[state.chatbuf].buftype = "nofile"
  vim.bo[state.chatbuf].bufhidden = "wipe"
  vim.bo[state.chatbuf].buflisted = false
  vim.bo[state.chatbuf].swapfile = false
  vim.bo[state.chatbuf].filetype = "markdown"
  vim.api.nvim_put({ M.chat_config.user_title, "" }, "c", true, true)
  state.chatclosed = false

  vim.keymap.set("n", "q", function()
    state.chatclosed = true
    close_gpt_win()
  end, { noremap = true, silent = true, buffer = state.chatbuf })
  vim.keymap.set("n", "<A-k>", function()
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = state.chatbuf })
  vim.keymap.set("i", "<A-k>", function()
    vim.cmd("stopinsert")
    M.gpt_chat()
  end, { noremap = true, silent = true, buffer = state.chatbuf })

  vim.api.nvim_buf_create_user_command(state.chatbuf, "GptSend", function()
    M.gpt_chat()
  end, { desc = "Gpt Send" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = state.chatbuf,
    callback = close_gpt_win,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = state.chatbuf,
    callback = close_gpt_win,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = state.chatbuf,
    callback = function()
      state.winleave = true
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = state.chatbuf,
    callback = function()
      state.cursormoved = true
    end,
  })
end

local function code_question(selection)
  if not selection then
    return
  end
  local qs
  ---@diagnostic disable-next-line: param-type-mismatch
  if vim.api.nvim_buf_is_valid(state.codebuf) then
    local filetype = vim.bo[state.codebuf].filetype or "text"
    local filename = vim.fn.fnamemodify(vim.fn.bufname(state.codebuf), ":.")
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
  table.insert(qs, "")
  vim.api.nvim_put(qs, "c", true, true)
end

---@class kai.ai.GptChatParam
---@field code? string[]
---@field question? string

---@param param kai.ai.GptChatParam
M.toggle_gpt = function(param)
  param = param or {}
  if state.chatwin then
    close_gpt_win()
  else
    create_gpt_win()
    if param.code then
      code_question(param.code)
    end
    if param.question then
      vim.api.nvim_put({ param.question, "" }, "c", true, true)
    end
  end
end

M.gpt_chat = function()
  if state.chatwin == nil then
    create_gpt_win()
  end
  if state.chatruning then
    vim.api.nvim_put({ "", M.chat_config.user_title, "" }, "c", true, true)
    state.chatruning = false
    return
  end
  state.chatruning = true
  ---@diagnostic disable-next-line: param-type-mismatch
  local list = vim.api.nvim_buf_get_lines(state.chatbuf, 0, -1, false)
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
    if state.chatclosed or state.chatruning == false then
      vim.fn.jobstop(opt.job)
      return
    end
    if opt.err == 1 then
      vim.notify("AI respond Error: " .. opt.data, vim.log.levels.WARN)
      return
    end
    if state.winleave then
      -- 防止回答问题时光标已经移动走了
      vim.api.nvim_set_current_win(state.chatwin)
      state.winleave = false
    end
    if state.cursormoved then
      -- 防止光标移动打乱回答顺序, 总是移动到最后一行
      vim.cmd("normal! G$")
      state.cursormoved = false
    end
    if done then
      vim.api.nvim_put({ "", "", M.chat_config.user_title, "" }, "c", true, true)
      state.chatruning = false
      return
    end
    if state.chatbuf and vim.api.nvim_buf_is_valid(state.chatbuf) then
      if data:match("\n") then
        local ln = vim.split(data, "\n")
        vim.api.nvim_put(ln, "c", true, true)
      else
        vim.api.nvim_put({ data }, "c", true, true)
      end
    end
  end

  require("kide.gpt.sse").request(json, callback)
end

return M
