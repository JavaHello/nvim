local M = {}
---@class kai.tools.TranslateRequest
---@field text string
---@field from string
---@field to string

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
  max_tokens = 4096 * 2,
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
    return "你会得到一个需要你检测语言的文本， 将他翻译为"
      .. request.to
      .. "。我只需要你翻译不要解释或回答我提供的文本"
  end
  return "你会得到一个"
    .. from
    .. "文本， 将他翻译为"
    .. request.to
    .. "。我只需要你翻译不要解释或回答我提供的文本"
end

---@param request kai.tools.TranslateRequest
---@param callback fun(data: string)
function M.translate(request, callback)
  local json = request_json
  json.messages[1].content = trans_system_prompt(request)
  json.messages[2].content = request.text
  require("kide.gpt.sse").request(json, callback)
end

local max_width = 120
local max_height = 40

M.translate_float = function(request)
  local codebuf = vim.api.nvim_get_current_buf()
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
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].number = false -- 不显示行号
  vim.wo[win].wrap = true
  if vim.api.nvim_buf_is_valid(codebuf) then
    local filetype = vim.bo[codebuf].filetype
    if filetype == "markdown" then
      vim.bo[buf].filetype = "markdown"
    end
  end

  local closed = false
  vim.keymap.set("n", "q", function()
    closed = true
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      closed = true
      pcall(vim.api.nvim_win_close, win, true)
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = buf,
    callback = function()
      closed = true
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    callback = function()
      closed = true
      pcall(vim.api.nvim_win_close, win, true)
    end,
  })

  local curlinelen = 0
  local count_line = 1
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

    local put_data = {}
    if vim.api.nvim_buf_is_valid(buf) then
      if data:match("\n") then
        put_data = vim.split(data, "\n")
      else
        put_data = { data }
      end
      for i, v in pairs(put_data) do
        if i > 1 then
          curlinelen = 0
          count_line = count_line + 1
        end
        curlinelen = curlinelen + vim.fn.strdisplaywidth(v)
        if curlinelen > width then
          if curlinelen < max_width or width ~= max_width then
            width = math.min(curlinelen, max_width)
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_width(win, width)
            end
          else
            curlinelen = 0
            count_line = count_line + 1
          end
        end
        if count_line > height and count_line <= max_height then
          height = count_line
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_height(win, height)
          end
        end
      end
      vim.api.nvim_put(put_data, "c", true, true)
    end
  end
  M.translate(request, callback)
end

return M
