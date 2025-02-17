local M = {}
local job = nil
local request_json = {
  messages = {
    {
      content = "帮我生成一个快速排序",
      role = "user",
    },
    {
      content = "```python\n",
      prefix = true,
      role = "assistant",
    },
  },
  model = "deepseek-chat",
  max_tokens = 4096 * 2,
  stop = "```",
  stream = true,
  temperature = 0.0,
}

function M.completions(param, callback)
  local json = request_json
  json.messages[1].content = param.message
  json.messages[2].content = "```" .. param.filetype .. "\n"
  job = require("kide.gpt.sse").request(json, callback, { url = "https://api.deepseek.com/beta/v1/chat/completions" })
end

M.code_completions = function(opts)
  local codebuf = vim.api.nvim_get_current_buf()
  local codewin = vim.api.nvim_get_current_win()
  local filetype = vim.bo[codebuf].filetype
  local closed = false
  local message
  if opts.inputcode then
    message = "```" .. filetype .. "\n" .. table.concat(opts.inputcode, "\n") .. "```\n" .. opts.message
    vim.api.nvim_win_set_cursor(codewin, { vim.fn.getpos("'>")[2] + 1, 0 })
  else
    message = opts.message
  end
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = codebuf,
    callback = function()
      closed = true
      if job then
        pcall(vim.fn.jobstop, job)
        job = nil
      end
    end,
  })

  vim.keymap.set("n", "<C-c>", function()
    closed = true
    if job then
      pcall(vim.fn.jobstop, job)
      job = nil
    end
    vim.keymap.del("n", "<C-c>", { buffer = codebuf })
  end, { buffer = codebuf, noremap = true, silent = true })

  local callback = function(opt)
    local data = opt.data
    if closed then
      vim.fn.jobstop(opt.job)
      return
    end
    if opt.done then
      return
    end

    local put_data = {}
    if vim.api.nvim_buf_is_valid(codebuf) then
      if data:match("\n") then
        put_data = vim.split(data, "\n")
      else
        put_data = { data }
      end
      vim.api.nvim_put(put_data, "c", true, true)
    end
  end
  M.completions({
    filetype = filetype,
    message = message,
  }, callback)
end

M.setup = function()
  local command = vim.api.nvim_buf_create_user_command
  local autocmd = vim.api.nvim_create_autocmd
  local function augroup(name)
    return vim.api.nvim_create_augroup("kide" .. name, { clear = true })
  end
  autocmd("FileType", {
    group = augroup("gpt_code_gen"),
    pattern = "*",
    callback = function(event)
      command(event.buf, "GptCode", function(opts)
        local code
        if opts.range > 0 then
          code = require("kide.tools").get_visual_selection()
        end
        M.code_completions({
          inputcode = code,
          message = opts.args,
        })
      end, {
        desc = "Gpt Code",
        nargs = "+",
        range = true,
      })
    end,
  })
end

return M
