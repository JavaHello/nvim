local M = {}
local gpt_provide = require("kide.gpt.provide")

---@class kide.gpt.Chat
---@field icon string
---@field title string
---@field client gpt.Client
---@field type string
---@field chatwin? number
---@field chatbuf? number
---@field codebuf? number
---@field chatclosed? boolean
---@field cursormoved? boolean
---@field chatruning? boolean
---@field winleave? boolean
---@field callback function
---@field chat_last string[]
local Chat = {}
Chat.__index = Chat

function M.new(opts)
  local self = setmetatable({}, Chat)
  self.icon = opts.icon
  self.title = opts.title
  self.type = opts.type
  self.chatwin = nil
  self.chatbuf = nil
  self.codebuf = nil
  self.chatclosed = true
  self.cursormoved = false
  self.chatruning = false
  self.winleave = false
  self.callback = opts.callback
  self.chat_last = {}
  return self
end

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
    .. "- Take a deep breath; You've got this!\n"
    .. "- All non-code text responses must be written in the Chinese language indicated.",
}

local function disable_start()
  vim.cmd("TSBufDisable highlight")
  vim.cmd("RenderMarkdown buf_disable")
end

local function enable_done()
  vim.cmd("TSBufEnable highlight")
  vim.cmd("RenderMarkdown buf_enable")
  vim.cmd("normal! G$")
end

function Chat:request()
  if self.chatruning then
    vim.api.nvim_put({ "", M.chat_config.user_title, "" }, "c", true, true)
    self.chatruning = false
    self.client:close()
    enable_done()
    return
  end
  self.chatruning = true
  ---@diagnostic disable-next-line: param-type-mismatch
  local list = vim.api.nvim_buf_get_lines(self.chatbuf, 0, -1, false)
  local messages = {
    {
      content = "",
      role = "system",
    },
  }

  messages[1].content = M.chat_config.system_prompt
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
      messages[chat_count] = {
        content = chat_msg,
        role = flag == 1 and "user" or "assistant",
      }
    end
  end
  -- 跳转到最后一行
  vim.cmd("normal! G$")
  disable_start()
  vim.api.nvim_put({ "", M.chat_config.system_title, "" }, "l", true, true)

  self.client:request(messages, self.callback(self))
end

---@param state kide.gpt.Chat
---@return function
local gpt_chat_callback = function(state)
  ---@param opt gpt.Event
  return function(opt)
    local data = opt.data
    local done = opt.done
    if opt.usage then
      require("kide").gpt_stl(
        state.chatbuf,
        state.icon,
        state.title,
        require("kide.gpt.toole").usage_str(state.client.model, opt.usage)
      )
    end
    if state.chatclosed or state.chatruning == false then
      state.client:close()
      enable_done()
      return
    end
    if opt.exit == 1 then
      vim.notify("AI respond Error: " .. opt.data, vim.log.levels.WARN)
      enable_done()
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
      state.chat_last = vim.api.nvim_buf_get_lines(state.chatbuf, 0, -1, true)
      enable_done()
      return
    end
    if state.chatbuf and vim.api.nvim_buf_is_valid(state.chatbuf) then
      if data and data:match("\n") then
        local ln = vim.split(data, "\n")
        vim.api.nvim_put(ln, "c", true, true)
      else
        vim.api.nvim_put({ data }, "c", true, true)
      end
    end
  end
end

---@param state kide.gpt.Chat
local gpt_reasoner_callback = function(state)
  local reasoning = 0
  ---@param opt gpt.Event
  return function(opt)
    if opt.usage then
      require("kide").gpt_stl(
        state.chatbuf,
        state.icon,
        state.title,
        require("kide.gpt.toole").usage_str(state.client.model, opt.usage)
      )
    end
    local data
    if opt.reasoning and opt.reasoning ~= vim.NIL then
      data = opt.reasoning
      if reasoning == 0 then
        reasoning = 1
      end
    elseif opt.data and opt.data ~= vim.NIL then
      if reasoning == 2 then
        reasoning = 3
      end
      data = opt.data
    end
    local done = opt.done
    if state.chatclosed or state.chatruning == false then
      state.client:close()
      enable_done()
      return
    end
    if opt.exit == 1 then
      vim.notify("AI respond Error: " .. opt.data, vim.log.levels.WARN)
      enable_done()
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
      state.chat_last = vim.api.nvim_buf_get_lines(state.chatbuf, 0, -1, true)
      enable_done()
      return
    end
    if state.chatbuf and vim.api.nvim_buf_is_valid(state.chatbuf) then
      data = data or ""
      if reasoning == 1 then
        reasoning = 2
        vim.api.nvim_put({ "<think>", "```text", "" }, "c", true, true)
      end
      if reasoning == 3 then
        reasoning = 4
        vim.api.nvim_put({ "", "```", "</think>", "---", "" }, "c", true, true)
      end
      if data:match("\n") then
        local ln = vim.split(data, "\n")
        vim.api.nvim_put(ln, "c", true, true)
      else
        vim.api.nvim_put({ data }, "c", true, true)
      end
    end
  end
end

function Chat:close_gpt_win()
  if self.chatwin then
    pcall(vim.api.nvim_win_close, self.chatwin, true)
    self.chatwin = nil
    self.chatbuf = nil
    self.codebuf = nil
    self.chatclosed = true
    self.cursormoved = false
    self.chatruning = false
    self.winleave = false
    self.client:close()
  end
end

function Chat:create_gpt_win()
  self.client = gpt_provide.new_client(self.type)
  self.codebuf = vim.api.nvim_get_current_buf()
  vim.cmd("belowright new")
  self.chatwin = vim.api.nvim_get_current_win()
  self.chatbuf = vim.api.nvim_get_current_buf()
  vim.bo[self.chatbuf].buftype = "nofile"
  vim.bo[self.chatbuf].bufhidden = "wipe"
  vim.bo[self.chatbuf].buflisted = false
  vim.bo[self.chatbuf].swapfile = false
  vim.bo[self.chatbuf].filetype = "markdown"
  vim.api.nvim_put({ M.chat_config.user_title, "" }, "c", true, true)
  self.chatclosed = false

  vim.keymap.set("n", "q", function()
    self.chatclosed = true
    self:close_gpt_win()
  end, { noremap = true, silent = true, buffer = self.chatbuf })
  vim.keymap.set("n", "<Enter>", function()
    self:request()
  end, { noremap = true, silent = true, buffer = self.chatbuf })
  vim.keymap.set("i", "<C-s>", function()
    vim.cmd("stopinsert")
    self:request()
  end, { noremap = true, silent = true, buffer = self.chatbuf })

  vim.api.nvim_buf_create_user_command(self.chatbuf, "GptSend", function()
    self:request()
  end, { desc = "Gpt Send" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = self.chatbuf,
    callback = function()
      self:close_gpt_win()
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = self.chatbuf,
    callback = function()
      self:close_gpt_win()
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = self.chatbuf,
    callback = function()
      self.winleave = true
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = self.chatbuf,
    callback = function()
      self.cursormoved = true
    end,
  })
  require("kide").gpt_stl(self.chatbuf, self.icon, self.title)
end

function Chat:code_question(selection)
  if not selection then
    return
  end
  local qs
  ---@diagnostic disable-next-line: param-type-mismatch
  if vim.api.nvim_buf_is_valid(self.codebuf) then
    local filetype = vim.bo[self.codebuf].filetype or "text"
    local filename = require("kide.stl").format_uri(vim.uri_from_bufnr(self.codebuf))
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

function Chat:question(question)
  vim.api.nvim_put({ question, "" }, "c", true, true)
end

local chat = M.new({
  icon = "󰭻",
  title = "GptChat",
  callback = gpt_chat_callback,
  type = "chat",
})

local reasoner = M.new({
  icon = "󰍦",
  title = "GptReasoner",
  callback = gpt_reasoner_callback,
  type = "reasoner",
})

---@class kai.gpt.ChatParam
---@field code? string[]
---@field question? string
---@field last? boolean
---@field reasoner? boolean

---@param param kai.gpt.ChatParam
M.toggle_gpt = function(param)
  param = param or {}
  local gpt
  if param.reasoner then
    gpt = reasoner
  else
    gpt = chat
  end
  if gpt.chatwin then
    gpt:close_gpt_win()
  else
    gpt:create_gpt_win()
    if param.last then
      gpt:gpt_last()
      return
    end
    if param.code then
      gpt:code_question(param.code)
    end
    if param.question then
      gpt:question(param.question)
    end
  end
end

function Chat:gpt_last(buf)
  if self.chat_last and #self.chat_last > 0 then
    vim.api.nvim_buf_set_lines(buf or self.chatbuf, 0, -1, true, self.chat_last)
    vim.cmd("normal! G$")
  end
end

return M
